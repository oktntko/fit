use crate::ui::common::Screen;
use log::debug;
use termion::event::Key;
use tui::{
  backend::Backend,
  layout::{Constraint, Direction, Layout, Rect},
  style::{Color, Modifier, Style},
  text::{Span, Spans},
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
  pub menu: Menu<'a, B>,
  pub debug_mode: bool,
}

impl<'a, B> App<'a, B>
where
  B: Backend,
{
  pub fn new() -> App<'a, B> {
    App {
      should_quit: false,
      menu: Menu::new(),
      debug_mode: false,
    }
  }

  pub fn draw(&mut self, f: &mut Frame<B>) {
    // menu
    let chunks = Layout::default()
      .constraints([Constraint::Length(3), Constraint::Min(0)].as_ref())
      .split(f.size());
    // TODO: screen の関数としてtitle()を定義するとエラーになる
    let titles = self
      .menu
      .titles
      .iter()
      .map(|t| Spans::from(Span::styled(*t, Style::default().fg(Color::Green))))
      .collect();
    let tabs = Tabs::new(titles)
      .block(Block::default().borders(Borders::ALL))
      .highlight_style(Style::default().fg(Color::Yellow))
      .select(self.menu.index);
    f.render_widget(tabs, chunks[0]);

    let chunk = if self.debug_mode {
      let chunks = Layout::default()
        .constraints([Constraint::Percentage(70), Constraint::Min(0)].as_ref())
        .direction(Direction::Horizontal)
        .split(chunks[1]);

      let block = Block::default().title("Debug").borders(Borders::ALL);
      f.render_widget(block, chunks[1]);

      chunks[0]
    } else {
      chunks[1]
    };

    // self.menu.current().draw(f, chunk)
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
      Key::F(u) => match u {
        12 => {
          self.debug_mode = !self.debug_mode;
        }
        _ => {}
      },
      _ => {}
    }
  }

  pub fn on_tick(&mut self) {}
}

pub struct Menu<'a, B>
where
  B: Backend,
{
  // TODO: screen と titleの一体化.
  pub titles: Vec<&'a str>,
  pub screens: Vec<&'a mut dyn Screen<B>>,
  pub index: usize,
}

impl<'a, B> Menu<'a, B>
where
  B: Backend,
{
  pub fn new() -> Menu<'a, B> {
    Menu {
      titles: vec![],
      screens: vec![],
      index: 1,
    }
  }

  pub fn current(&mut self) -> &mut dyn Screen<B> {
    self.screens[self.index]
  }

  pub fn next(&mut self) {
    self.index = (self.index + 1) % self.screens.len();
  }

  pub fn previous(&mut self) {
    if self.index > 0 {
      self.index -= 1;
    } else {
      self.index = self.screens.len() - 1;
    }
  }
}
