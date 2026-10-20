//! The egui UI.
//!
//! Plain Rust: the same code runs on Android and on the desktop, so you can
//! iterate with `cargo run` and only reach for the phone when it matters.
//! Replace this with your own screens.

use std::time::Duration;

use eframe::egui::{self, Color32, RichText};

use crate::Platform;

const BACKGROUND: Color32 = Color32::from_rgb(17, 24, 39);
const DIM: Color32 = Color32::from_rgb(148, 163, 184);

pub struct TemplateApp {
    platform: Platform,
    taps: u32,
}

impl TemplateApp {
    pub fn new(ctx: &egui::Context, platform: Platform) -> Self {
        let mut visuals = egui::Visuals::dark();
        visuals.panel_fill = BACKGROUND;
        visuals.window_fill = BACKGROUND;
        visuals.override_text_color = Some(Color32::from_rgb(226, 232, 240));
        ctx.set_visuals(visuals);

        Self { platform, taps: 0 }
    }

    /// Android's back button arrives as a key press (`NativeActivity` swallows
    /// `KEYCODE_BACK`, but winit turns it into `NamedKey::BrowserBack`).
    /// Returns true when the app is on its way out.
    fn handle_back_button(&mut self, ctx: &egui::Context) -> bool {
        let pressed = ctx.input(|input| {
            input.events.iter().any(|event| {
                matches!(
                    event,
                    egui::Event::Key {
                        key: egui::Key::BrowserBack,
                        pressed: true,
                        ..
                    }
                )
            })
        });

        if pressed {
            self.platform.quit(ctx);
        }
        pressed
    }

    /// Paint the whole UI.
    ///
    /// Kept apart from [`eframe::App::update`] so it can be exercised without a
    /// window or an audio device (see the tests at the bottom).
    fn draw(&mut self, ctx: &egui::Context) {
        let size = ctx.screen_rect().size();

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.vertical_centered(|ui| {
                ui.add_space(32.0);
                ui.label(RichText::new("Hello, Android").size(32.0).strong());
                ui.add_space(8.0);

                // Handy while adapting a layout: the logical size is what the
                // UI actually gets, and it changes when the phone is folded or
                // the window is resized.
                ui.label(
                    RichText::new(format!(
                        "viewport {:.0} x {:.0} pt @ {:.2}x",
                        size.x,
                        size.y,
                        ctx.pixels_per_point()
                    ))
                    .size(13.0)
                    .color(DIM),
                );

                ui.add_space(24.0);
                if ui
                    .add_sized(
                        [200.0, 44.0],
                        egui::Button::new(
                            RichText::new(format!("tapped {} times", self.taps)).size(18.0),
                        ),
                    )
                    .clicked()
                {
                    self.taps += 1;
                }

                ui.add_space(24.0);
                ui.label(RichText::new("press back to quit").size(12.0).color(DIM));
            });
        });
    }
}

impl eframe::App for TemplateApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        if self.handle_back_button(ctx) {
            return;
        }
        self.draw(ctx);

        // No animation going on, so egui only repaints on input. Drop this line
        // if you add something that changes without user interaction.
        ctx.request_repaint_after(Duration::from_secs(1));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn frame(app: &mut TemplateApp, ctx: &egui::Context, events: Vec<egui::Event>) -> Vec<String> {
        let input = egui::RawInput {
            screen_rect: Some(egui::Rect::from_min_size(
                egui::Pos2::ZERO,
                egui::vec2(360.0, 800.0),
            )),
            events,
            ..Default::default()
        };

        let mut texts = Vec::new();
        let output = ctx.run(input, |ctx| app.draw(ctx));

        for clipped in &output.shapes {
            assert!(
                clipped.shape.visual_bounding_rect().is_finite(),
                "a shape was painted with non-finite bounds"
            );
            collect_text(&clipped.shape, &mut texts);
        }
        texts
    }

    fn collect_text(shape: &egui::Shape, out: &mut Vec<String>) {
        match shape {
            egui::Shape::Text(text) => out.push(text.galley.text().to_owned()),
            egui::Shape::Vec(shapes) => {
                for shape in shapes {
                    collect_text(shape, out);
                }
            }
            _ => {}
        }
    }

    #[test]
    fn paints_the_ui() {
        let ctx = egui::Context::default();
        let mut app = TemplateApp::new(&ctx, crate::Platform::new());

        let texts = frame(&mut app, &ctx, vec![]);
        assert!(
            texts.iter().any(|text| text == "Hello, Android"),
            "texts: {texts:?}"
        );
        assert!(
            texts.iter().any(|text| text.contains("viewport")),
            "texts: {texts:?}"
        );

        // A second frame shows the counter in the button.
        app.taps = 3;
        let texts = frame(&mut app, &ctx, vec![]);
        assert!(
            texts.iter().any(|text| text.contains("tapped 3 times")),
            "texts: {texts:?}"
        );
    }

    #[test]
    fn back_button_quits() {
        let ctx = egui::Context::default();
        let mut app = TemplateApp::new(&ctx, crate::Platform::new());

        let back = egui::Event::Key {
            key: egui::Key::BrowserBack,
            physical_key: None,
            pressed: true,
            repeat: false,
            modifiers: egui::Modifiers::NONE,
        };
        let input = egui::RawInput {
            screen_rect: Some(egui::Rect::from_min_size(
                egui::Pos2::ZERO,
                egui::vec2(360.0, 800.0),
            )),
            events: vec![back],
            ..Default::default()
        };

        let mut quitting = false;
        let output = ctx.run(input, |ctx| quitting = app.handle_back_button(ctx));
        let closed = output
            .viewport_output
            .values()
            .any(|viewport| viewport.commands.contains(&egui::ViewportCommand::Close));

        assert!(quitting, "back did not request a quit");
        assert!(closed, "no close command was sent");
    }
}
