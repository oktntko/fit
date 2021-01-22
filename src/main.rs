use log::debug;
use log4rs;
mod event;

use argh::FromArgs;
use event::{Config, Event, Events};
use std::{error::Error, io};
use termion::{event::Key, input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::{
  backend::TermionBackend,
  widgets::{Block, Borders},
  Terminal,
};

/// Termion demo
#[derive(Debug, FromArgs)]
struct Cli {
  /// time in ms between two ticks.
  #[argh(option, default = "250")]
  tick_rate: u64,
  /// whether unicode symbols are used to improve the overall look of the app
  #[argh(option, default = "true")]
  enhanced_graphics: bool,
}

fn main() -> Result<(), Box<dyn Error>> {
  // -- init start -- //
  // init log
  log4rs::init_file("log4rs.yaml", Default::default()).unwrap();

  let cli: Cli = argh::from_env();

  // raw mode
  let stdout = io::stdout().into_raw_mode()?;
  // termion <- stdout
  let stdout = MouseTerminal::from(stdout);
  let stdout = AlternateScreen::from(stdout);
  let backend = TermionBackend::new(stdout);
  // tui <- termion
  let mut terminal = Terminal::new(backend)?;

  // event reciever & sender
  let events = Events::new(Config::default());

  // -- init end -- //

  loop {
    terminal.draw(|f| {
      debug!("terminal.draw");
      let size = f.size();
      let block = Block::default().title("Block").borders(Borders::ALL);
      f.render_widget(block, size);
    });

    match events.next()? {
      Event::Input(key) => match key {
        Key::Char(c) => match c {
          'q' => {
            break;
          }
          't' => {
            break;
          }
          _ => {}
        },
        Key::Up => {}
        Key::Down => {}
        Key::Left => {}
        Key::Right => {}
        _ => {}
      },
      Event::Tick => {}
    }
  }

  Ok(())
}
