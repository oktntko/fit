pub trait View<B>
where
  B: tui::backend::Backend,
{
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect);
  fn reload(&mut self);
  fn on_key_event(&mut self, key: termion::event::Key);
  fn on_entered(&mut self);
  fn on_left(&mut self);
}
