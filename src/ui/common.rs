pub trait Screen<B: tui::backend::Backend> {
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect);
  fn reload(&mut self);
  fn on_key_event(&mut self, key: termion::event::Key);
}
