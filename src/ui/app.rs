use crate::ui::common::Screen;
use crate::ui::screen::status::Status;
use log::{debug, warn};
use std::{
  io::{BufRead, BufReader, Read},
  process::{Command, Stdio},
  sync::{mpsc, Arc, Mutex},
  thread,
};
use termion::event::Key;
use tui::{
  backend::Backend,
  layout::{Constraint, Direction, Layout, Rect},
  style::{Color, Modifier, Style},
  text::{Span, Spans},
  widgets::{Block, Borders, List, ListItem, ListState, Tabs},
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
  debug_mode: bool,
  debug_screen: Box<dyn Screen<B>>,
  // TODO: screen の関数としてtitle()を定義するとエラーになる
  titles: Vec<&'a str>,
  menu: Vec<Box<dyn Screen<B>>>,
  selected_menu_index: usize,
}

impl<'a, B> App<'a, B>
where
  B: Backend,
{
  pub fn new() -> App<'a, B> {
    App {
      should_quit: false,
      debug_mode: false,
      debug_screen: Box::new(Debug::new()),
      titles: vec!["status", "hoge"],
      menu: vec![Box::new(Status::new()), Box::new(Status::new())],
      selected_menu_index: 0,
    }
  }

  pub fn draw(&mut self, f: &mut Frame<B>) {
    // debug
    let chunk = if self.debug_mode {
      let chunks = Layout::default()
        .constraints([Constraint::Percentage(70), Constraint::Min(0)].as_ref())
        .direction(Direction::Horizontal)
        .split(f.size());

      self.debug_screen.draw(f, chunks[1]);

      chunks[0]
    } else {
      let chunks = Layout::default()
        .constraints([Constraint::Percentage(100)].as_ref())
        .split(f.size());

      chunks[0]
    };

    // menu
    let chunks = Layout::default()
      .constraints([Constraint::Length(3), Constraint::Min(0)].as_ref())
      .split(chunk);
    let titles = self
      .titles
      .iter()
      .map(|t| Spans::from(Span::styled(*t, Style::default().fg(Color::Green))))
      .collect();
    let tabs = Tabs::new(titles)
      .block(Block::default().borders(Borders::ALL))
      .highlight_style(Style::default().fg(Color::Yellow))
      .select(self.selected_menu_index);
    f.render_widget(tabs, chunks[0]);

    self.menu[self.selected_menu_index].draw(f, chunks[1]);
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
          if self.debug_mode {
            self.debug_screen.on_entered();
          } else {
            self.debug_screen.on_left();
          }
        }
        _ => {}
      },
      Key::Char(c) => match c {
        '\t' => {
          self.next();
        }
        _ => {}
      },
      Key::BackTab => {
        self.previous();
      }
      _ => {}
    }
  }

  pub fn on_tick(&mut self) {}

  fn next(&mut self) {
    self.selected_menu_index = (self.selected_menu_index + 1) % self.menu.len();
  }

  fn previous(&mut self) {
    if self.selected_menu_index > 0 {
      self.selected_menu_index -= 1;
    } else {
      self.selected_menu_index = self.menu.len() - 1;
    }
  }
}

struct Debug {
  pub state: ListState,
}

impl Debug {
  pub fn new() -> Debug {
    Debug {
      state: ListState::default(),
    }
  }
}

impl<B> Screen<B> for Debug
where
  B: tui::backend::Backend,
{
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
    let mut child = Command::new("tail")
      .args(&["--silent", "-n", "100", "fit.log"])
      .current_dir("./log")
      .stdin(Stdio::null())
      .stdout(Stdio::piped())
      .stderr(Stdio::null())
      .spawn()
      .unwrap();
    let mut reader = BufReader::new(child.stdout.take().unwrap());

    let mut buf = vec![];
    if let Err(e) = reader.read_to_end(&mut buf) {
      warn!("cannot kill process: {}", e);
    } else {
      let lines = std::str::from_utf8(&buf).unwrap();
      let lines: Vec<ListItem> = lines
        .lines()
        .map(|i| ListItem::new(vec![Spans::from(Span::raw(i))]))
        .collect();
      self.state.select(Some(lines.len() - 1));
      let lines = List::new(lines)
        .block(Block::default().title("Debug").borders(Borders::ALL))
        .highlight_style(Style::default().add_modifier(Modifier::BOLD))
        .highlight_symbol("❯ ");
      f.render_stateful_widget(lines, area, &mut self.state);
    }
  }
  fn reload(&mut self) {}
  fn on_key_event(&mut self, key: termion::event::Key) {}
  fn on_entered(&mut self) {
    self.state = ListState::default();
  }
  fn on_left(&mut self) {
    self.state = ListState::default();
  }
}
