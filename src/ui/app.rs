use crate::ui::common::Tab;
use log::debug;
use termion::event::Key;
use tui::backend::Backend;
use tui::{
  widgets::{Block, Borders, Tabs},
  Frame,
};
// +-----------------------------------------------------------------+
// |-----------------------------------------------------------------|
// ||tabs                                                           ||
// |-----------------------------------------------------------------|
// |-----------------------------------------------------------------|
// ||main contents                                 ||debug log      ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// ||                                              ||               ||
// |-----------------------------------------------------------------|
// +-----------------------------------------------------------------+

pub struct App<'a, B>
where
  B: Backend,
{
  pub should_quit: bool,
  pub tabs: TabsState<'a, B>,
  pub debug_mode: bool,
}

impl<'a, B> App<'a, B>
where
  B: Backend,
{
  pub fn new() -> App<'a, B> {
    App {
      should_quit: false,
      tabs: TabsState::new(),
      debug_mode: false,
    }
  }

  pub fn draw(&mut self, f: &mut Frame<B>) {
    let size = f.size();
    let block = Block::default().title("Block").borders(Borders::ALL);
    f.render_widget(block, size);
  }

  pub fn on_key_event(&mut self, key: Key) {
    debug!("on_key {:?}", key);
    match key {
      Key::Ctrl(c) => match c {
        'c' => {
          self.should_quit = true;
        }
        _ => {}
      },
      _ => {}
    }
  }

  pub fn on_tick(&mut self) {}
}

pub struct TabsState<'a, B>
where
  B: Backend,
{
  pub tabs: Vec<&'a dyn Tab<B>>,
  pub index: usize,
}

impl<'a, B> TabsState<'a, B>
where
  B: Backend,
{
  pub fn new() -> TabsState<'a, B> {
    TabsState {
      tabs: vec![],
      index: 1,
    }
  }
  pub fn next(&mut self) {
    self.index = (self.index + 1) % self.tabs.len();
  }

  pub fn previous(&mut self) {
    if self.index > 0 {
      self.index -= 1;
    } else {
      self.index = self.tabs.len() - 1;
    }
  }
}
