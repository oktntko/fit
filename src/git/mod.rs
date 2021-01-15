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
use git2::{Error, ErrorCode, Repository, StatusOptions, SubmoduleIgnore};

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
  let statuses = repo.statuses(Some(&mut opts)).unwrap();

  // let output = Command::new("exa")
  //   // プロセスを実行するディレクトリを指定する
  //   .current_dir("./")
  //   .output()
  //   .expect("failed to execute process");

  // let hello: Vec<u8> = output.stdout;

  // let exa: &str = std::str::from_utf8(&hello).unwrap();

  let output = Command::new("git")
    .current_dir("./")
    .arg("-c")
    .arg("color.status=always")
    .arg("log")
    .arg("--oneline")
    .output()
    .expect("failed to execute process");

  let hello: Vec<u8> = output.stdout;

  // let pattern = Regex::new(
  //   r"(?x)
  // ([0-9a-fA-F]+) # commit hash
  // (.*)           # The commit message",
  // )
  // .unwrap();

  let text: Vec<_> = std::str::from_utf8(&hello)
    .unwrap()
    .lines()
    .map(|cap| Spans::from(cap))
    .take(5)
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
