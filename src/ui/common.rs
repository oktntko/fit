pub trait Drawable {
  fn draw<B: tui::backend::Backend>(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect);
}

pub trait Reloadable {
  fn reload(&mut self);
}

pub trait KeyHandlable {
  fn on_key_event(&mut self, key: termion::event::Key);
  fn on_entered(&mut self);
  fn on_left(&mut self);
}
