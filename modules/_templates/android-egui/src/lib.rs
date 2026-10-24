//! Entry points: a normal desktop window, and Android's `android_main`.
//!
//! The Android build is a `cdylib` that the system loads as a shared library
//! (`android.app.NativeActivity` + `android:hasCode="false"`), so there is no
//! Java or Gradle in this project. `android_main` is the equivalent of `main`.

pub mod app;

pub use app::TemplateApp;

use eframe::egui;

/// Everything that differs between Android and the desktop.
pub struct Platform {
    #[cfg(target_os = "android")]
    android: winit::platform::android::activity::AndroidApp,
}

impl Platform {
    #[cfg(target_os = "android")]
    fn new_android(android: winit::platform::android::activity::AndroidApp) -> Self {
        // Delete this if your app should be allowed to sleep.
        keep_screen_on(&android);
        Self { android }
    }

    #[cfg(not(target_os = "android"))]
    fn new() -> Self {
        Self {}
    }

    /// Close the app (back button, or closing the window on the desktop).
    fn quit(&self, ctx: &egui::Context) {
        #[cfg(target_os = "android")]
        {
            // `finish()` is what the back button normally does. Android then
            // waits for `android_main` to return before it completes
            // `onDestroy`, so the event loop has to stop as well - otherwise
            // the Activity is left half-destroyed and the process wedges.
            finish_activity(&self.android);
        }
        ctx.send_viewport_cmd(egui::ViewportCommand::Close);
    }
}

fn native_options() -> eframe::NativeOptions {
    eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([380.0, 720.0])
            .with_min_inner_size([240.0, 240.0])
            .with_title("Template"),
        renderer: eframe::Renderer::Glow,
        vsync: true,
        ..Default::default()
    }
}

/// Run the app in a normal window (development).
#[cfg(not(target_os = "android"))]
pub fn run_desktop() -> eframe::Result<()> {
    let platform = Platform::new();
    eframe::run_native(
        "Template",
        native_options(),
        Box::new(move |cc| Ok(Box::new(TemplateApp::new(&cc.egui_ctx, platform)))),
    )
}

#[cfg(target_os = "android")]
#[unsafe(no_mangle)]
// The signature is dictated by `android-activity` (and winit).
#[allow(improper_ctypes_definitions)]
pub extern "C" fn android_main(app: winit::platform::android::activity::AndroidApp) {
    init_logging();
    log::info!("starting template");

    let platform = Platform::new_android(app.clone());
    // Keep a handle for the error path below.
    let app_for_finish = app.clone();

    let mut options = native_options();
    options.android_app = Some(app);

    if let Err(err) = eframe::run_native(
        "Template",
        options,
        Box::new(move |cc| Ok(Box::new(TemplateApp::new(&cc.egui_ctx, platform)))),
    ) {
        log::error!("template exited with an error: {err}");
        // Typically `EventLoop can't be recreated`: Android reused a cached
        // process whose Activity had already finished. There is no UI to show,
        // so close the Activity instead of leaving a blank window.
        finish_activity(&app_for_finish);
    }

    // winit can only ever create one event loop per process, so a process that
    // outlives its Activity could never show the app again - and Android keeps
    // finished processes cached for the next launch. End the process now that
    // the Activity is gone; the next launch then starts from a clean slate.
    log::info!("activity is gone, exiting");
    std::process::exit(0);
}

#[cfg(target_os = "android")]
fn init_logging() {
    android_logger::init_once(
        android_logger::Config::default()
            .with_max_level(log::LevelFilter::Info)
            .with_tag("template"),
    );
}

// ---------------------------------------------------------------------------
// JNI helpers
//
// Calling Java from Rust is how `NativeActivity` apps do anything that needs
// the Android framework. The patterns worth knowing:
//
// * `Activity.finish()` -> see below.
// * Window flags: `getWindow().addFlags(FLAG_KEEP_SCREEN_ON)` (see
//   `keep_screen_on` below) keeps the display awake while the app is visible.
// * Runtime permissions (camera, microphone, ...): call
//   `checkSelfPermission(String) -> int` (0 means granted) and, if it is not,
//   `requestPermissions(String[], int)`. Both are plain `Activity` methods, so
//   the same `call_method` approach works; then poll `checkSelfPermission`
//   until the user answers.
// ---------------------------------------------------------------------------

/// Run `f` on the current thread with a `JNIEnv`.
#[cfg(target_os = "android")]
fn with_env<R>(
    app: &winit::platform::android::activity::AndroidApp,
    f: impl FnOnce(&mut jni::JNIEnv) -> R,
) -> Option<R> {
    let vm = unsafe { jni::JavaVM::from_raw(app.vm_as_ptr() as *mut jni::sys::JavaVM) }.ok()?;
    let mut env = match vm.attach_current_thread() {
        Ok(env) => env,
        Err(err) => {
            log::warn!("could not attach to the JVM: {err}");
            return None;
        }
    };
    Some(f(&mut env))
}

/// Borrow the Activity as a `JObject` without taking ownership of the JNI ref
/// (`ManuallyDrop` stops `jni` from deleting a reference it does not own).
#[cfg(target_os = "android")]
fn activity_object(
    app: &winit::platform::android::activity::AndroidApp,
) -> std::mem::ManuallyDrop<jni::objects::JObject<'static>> {
    unsafe {
        std::mem::ManuallyDrop::new(jni::objects::JObject::from_raw(
            app.activity_as_ptr() as jni::sys::jobject
        ))
    }
}

/// `Activity.finish()` — close the app and go back to the launcher.
#[cfg(target_os = "android")]
fn finish_activity(app: &winit::platform::android::activity::AndroidApp) {
    with_env(app, |env| {
        let activity = activity_object(app);
        // `finish()` takes no arguments; passing JValue::Void here makes the
        // JNI call fail with "invalid number of arguments".
        if let Err(err) = env.call_method(&*activity, "finish", "()V", &[]) {
            log::warn!("could not finish the activity: {err}");
        }
    });
}

/// `getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)`.
///
/// Keeps the display awake while the app is in the foreground, without any
/// permission. The flag stops applying on its own once the window is hidden, so
/// there is nothing to release when the app goes to the background.
#[cfg(target_os = "android")]
fn keep_screen_on(app: &winit::platform::android::activity::AndroidApp) {
    use jni::objects::{JObject, JValue};

    /// `WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON`
    const FLAG_KEEP_SCREEN_ON: i32 = 0x0000_0080;

    with_env(app, |env| {
        let activity = activity_object(app);
        let result = (|| -> jni::errors::Result<()> {
            let window = env
                .call_method(&*activity, "getWindow", "()Landroid/view/Window;", &[])?
                .l()?;
            let window: &JObject = &window;
            env.call_method(
                window,
                "addFlags",
                "(I)V",
                &[JValue::Int(FLAG_KEEP_SCREEN_ON)],
            )?;
            Ok(())
        })();
        match result {
            Ok(()) => log::info!("keeping the screen on"),
            Err(err) => log::warn!("could not keep the screen on: {err}"),
        }
    });
}
