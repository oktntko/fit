use std::process::Command;
use tui::{
  backend::Backend,
  layout::Rect,
  style::{Color, Modifier, Style},
  text::{Span, Spans},
  widgets::canvas::{Canvas, Line, Map, MapResolution, Rectangle},
  widgets::{
    Axis, BarChart, Block, Borders, Cell, Chart, Dataset, Gauge, LineGauge, List, ListItem,
    Paragraph, Row, Sparkline, Table, Tabs, Wrap,
  },
  Frame,
};
#[derive(PartialEq, Default, Clone, Debug)]
struct Commit {
  hash: String,
  message: String,
}
use git2::{Error, ErrorClass, ErrorCode, Repository, Status, StatusOptions, SubmoduleIgnore};

///
#[derive(Copy, Clone, Hash, PartialEq, Debug)]
pub enum StatusItemType {
  ///
  New,
  ///
  Modified,
  ///
  Deleted,
  ///
  Renamed,
  ///
  Typechange,
}
///
#[derive(Clone, Hash, PartialEq, Debug)]
pub struct StatusItem {
  ///
  pub path: String,
  ///
  pub status: StatusItemType,
}

impl From<Status> for StatusItemType {
  fn from(s: Status) -> Self {
    if s.is_index_new() || s.is_wt_new() {
      Self::New
    } else if s.is_index_deleted() || s.is_wt_deleted() {
      Self::Deleted
    } else if s.is_index_renamed() || s.is_wt_renamed() {
      Self::Renamed
    } else if s.is_index_typechange() || s.is_wt_typechange() {
      Self::Typechange
    } else {
      Self::Modified
    }
  }
}
pub fn draw_status<B>(f: &mut Frame<B>, area: Rect)
where
  B: Backend,
{
  let path = ".".to_string();
  let repo = Repository::open(&path).unwrap();
  if repo.is_bare() {
    // return Err(Error::from_str("cannot report status on bare repository"));
  }
  let mut opts = StatusOptions::new();
  opts.include_untracked(true).recurse_untracked_dirs(true);
  let statuses = repo.statuses(Some(&mut opts)).unwrap();

  let text: Vec<_> = statuses
    .iter()
    .map(|e| {
      let status: Status = e.status();
      let path = std::str::from_utf8(e.path_bytes()).unwrap().to_string();

      return StatusItem {
        path,
        status: StatusItemType::from(status),
      };
    })
    .map(|e| e.path)
    .map(|e| Spans::from(e))
    .collect();
  // let text = vec![
  //   Spans::from(exa),
  //   Spans::from(""),
  //   Spans::from(vec![
  //     Span::from("For example: "),
  //     Span::styled("under", Style::default().fg(Color::Red)),
  //     Span::raw(" "),
  //     Span::styled("the", Style::default().fg(Color::Green)),
  //     Span::raw(" "),
  //     Span::styled("rainbow", Style::default().fg(Color::Blue)),
  //     Span::raw("."),
  //   ]),
  //   Spans::from(vec![
  //     Span::raw("Oh and if you didn't "),
  //     Span::styled("notice", Style::default().add_modifier(Modifier::ITALIC)),
  //     Span::raw(" you can "),
  //     Span::styled(
  //       "automatically",
  //       Style::default().add_modifier(Modifier::BOLD),
  //     ),
  //     Span::raw(" "),
  //     Span::styled("wrap", Style::default().add_modifier(Modifier::REVERSED)),
  //     Span::raw(" your "),
  //     Span::styled("text", Style::default().add_modifier(Modifier::UNDERLINED)),
  //     Span::raw("."),
  //   ]),
  //   Spans::from("One more thing is that it should display unicode characters: 10€"),
  // ];
  let block = Block::default().borders(Borders::ALL).title(Span::styled(
    "Footer",
    Style::default()
      .fg(Color::Magenta)
      .add_modifier(Modifier::BOLD),
  ));
  let paragraph = Paragraph::new(text).block(block).wrap(Wrap { trim: true });
  f.render_widget(paragraph, area);
}
