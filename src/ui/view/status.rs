use crate::api::git::{FitStatus, Git};
use crate::ui::common::View;
use log::debug;
use tui::{
  layout::{Constraint, Layout},
  style::{Color, Modifier, Style},
  text::Text,
  widgets::{Block, Borders, Cell, Row, Table, TableState},
};

pub struct Status {
  statuses: Vec<FitStatus>,
  state: TableState,
}

impl Status {
  pub fn new() -> Status {
    Status {
      statuses: vec![],
      state: TableState::default(),
    }
  }
}

impl<B> View<B> for Status
where
  B: tui::backend::Backend,
{
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
    let chunks = Layout::default()
      .constraints([Constraint::Percentage(100)].as_ref())
      .split(area);

    let selected_style = Style::default().add_modifier(Modifier::REVERSED);
    let normal_style = Style::default().bg(Color::Blue);
    let header_cells = ["Header1", "Header2", "Header3"]
      .iter()
      .map(|h| Cell::from(*h).style(Style::default().fg(Color::Red)));
    let header = Row::new(header_cells)
      .style(normal_style)
      .height(1)
      .bottom_margin(1);
    let rows = self.statuses.iter().map(|status| {
      debug!("status {:?}", status);
      let cells = vec![Cell::from(Text::from(status.path.as_ref()))];
      Row::new(cells).bottom_margin(1)
    });
    let t = Table::new(rows)
      .header(header)
      .block(Block::default().borders(Borders::ALL).title("Table"))
      .highlight_style(selected_style)
      .highlight_symbol(">> ")
      .widths(&[
        Constraint::Percentage(50),
        Constraint::Length(30),
        Constraint::Max(10),
      ]);
    f.render_stateful_widget(t, chunks[0], &mut self.state);
  }

  fn reload(&mut self) {
    let git = Git::new();
    let statuses = git.status();
    debug!("status {:?}", statuses);
    self.statuses = statuses;
  }

  fn on_key_event(&mut self, key: termion::event::Key) {
    debug!("key {:?}", key);
  }

  fn on_entered(&mut self) {
    // self.reload();
  }

  fn on_left(&mut self) {}
}
