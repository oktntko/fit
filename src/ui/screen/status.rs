use crate::ui::common::Screen;
use log::debug;
use tui::{
  layout::{Constraint, Layout},
  widgets::{Block, Borders},
};

pub struct Status<'a> {
  status: &'a str,
}

impl<'a> Status<'a> {
  pub fn new() -> Status<'a> {
    Status { status: "good" }
  }
}

impl<'a, B> Screen<B> for Status<'a>
where
  B: tui::backend::Backend,
{
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
    let chunks = Layout::default()
      .constraints([Constraint::Percentage(100)].as_ref())
      .split(area);
    let block = Block::default().title("Block").borders(Borders::ALL);
    f.render_widget(block, chunks[0]);
  }
  fn reload(&mut self) {}
  fn on_key_event(&mut self, key: termion::event::Key) {
    debug!("key {:?}", key);
  }
}
