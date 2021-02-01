use crate::ui::common::{Drawable, KeyHandlable, Reloadable};
use log::warn;
use std::{
  io::{BufReader, Read},
  process::{Command, Stdio},
};
use tui::{
  style::{Modifier, Style},
  text::{Span, Spans},
  widgets::{Block, Borders, List, ListItem, ListState},
};

pub struct Console {
  pub state: ListState,
}

impl Console {
  pub fn new() -> Console {
    Console {
      state: ListState::default(),
    }
  }
}

impl Drawable for Console {
  fn draw<B: tui::backend::Backend>(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
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
        .block(Block::default().title("Console").borders(Borders::ALL))
        .highlight_style(Style::default().add_modifier(Modifier::BOLD))
        .highlight_symbol("❯ ");
      f.render_stateful_widget(lines, area, &mut self.state);
    }
  }
}

impl Reloadable for Console {
  fn reload(&mut self) {}
}

impl KeyHandlable for Console {
  fn on_key_event(&mut self, key: termion::event::Key) {}
  fn on_entered(&mut self) {
    self.state = ListState::default();
  }
  fn on_left(&mut self) {
    self.state = ListState::default();
  }
}
