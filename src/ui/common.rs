use tui::backend::Backend;
use tui::Frame;

pub trait Tab<B: Backend> {
  fn draw(&mut self, f: &mut Frame<B>, area: tui::layout::Rect);
  fn reload(&mut self);
  fn on_key_event(&mut self, key: termion::event::Key);
}
