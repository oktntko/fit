use crate::ui::common::{Drawable, KeyHandlable, Reloadable};
use crate::ui::view::{console::Console, status::Status};
use log::{debug, error};
use termion::event::Key;
use tui::{
  layout::{Constraint, Direction, Layout},
  style::{Color, Style},
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

pub struct App {
  pub should_quit: bool,
  debug_mode: bool,
  debug_screen: Console,
  menu: Menu,
}

impl App {
  pub fn new() -> App {
    App {
      should_quit: false,
      debug_mode: false,
      debug_screen: Console::new(),
      menu: Menu::new(),
    }
  }

  pub fn draw<B: tui::backend::Backend>(&mut self, f: &mut Frame<B>) {
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

    self.menu.draw(f, chunk);
  }

  pub fn on_key_event(&mut self, key: Key) {
    debug!("on_key {:?}", key);
    match key {
      Key::Ctrl(c) => match c {
        'c' => self.should_quit = true,
        _ => self.menu.on_key_event(key),
      },
      Key::F(u) => match u {
        5 => self.menu.reload(),
        12 => {
          self.debug_mode = !self.debug_mode;
          if self.debug_mode {
            self.debug_screen.on_entered();
          } else {
            self.debug_screen.on_left();
          }
        }
        _ => self.menu.on_key_event(key),
      },
      Key::Char(c) => match c {
        '\t' => self.menu.next(),
        _ => self.menu.on_key_event(key),
      },
      Key::BackTab => self.menu.previous(),
      _ => self.menu.on_key_event(key),
    }
  }

  pub fn on_tick(&mut self) {}
}

struct Menu {
  pub titles: Vec<String>,
  pub index: usize,
  pub status: Status,
}

impl Menu {
  pub fn new() -> Menu {
    Menu {
      titles: vec!["status".to_string(), "hoge".to_string()],
      index: 0,
      status: Status::new(),
    }
  }

  pub fn draw<B: tui::backend::Backend>(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
    let chunks = Layout::default()
      .constraints([Constraint::Length(3), Constraint::Min(0)].as_ref())
      .split(area);
    let titles = self
      .titles
      .iter()
      .map(|t| Spans::from(Span::styled(t, Style::default().fg(Color::Green))))
      .collect();
    let tabs = Tabs::new(titles)
      .block(Block::default().borders(Borders::ALL))
      .highlight_style(Style::default().fg(Color::Yellow))
      .select(self.index);
    f.render_widget(tabs, chunks[0]);

    match self.index {
      0 => self.status.draw(f, chunks[1]),
      _ => error!("unknown tab"),
    }
  }

  fn move_tab_index(&mut self, index: usize) {
    match self.index {
      0 => self.status.on_left(),
      _ => error!("unknown tab"),
    }
    self.index = index;
    match self.index {
      0 => self.status.on_entered(),
      _ => error!("unknown tab"),
    }
  }

  pub fn reload(&mut self) {
    match self.index {
      0 => self.status.reload(),
      _ => error!("unknown tab"),
    }
  }

  pub fn on_key_event(&mut self, key: termion::event::Key) {
    match self.index {
      0 => self.status.on_key_event(key),
      _ => error!("unknown tab"),
    }
  }

  pub fn next(&mut self) {
    self.move_tab_index((self.index + 1) % self.titles.len());
  }

  pub fn previous(&mut self) {
    if self.index > 0 {
      self.index -= 1;
    } else {
      self.index = self.titles.len() - 1;
    }
  }
}
