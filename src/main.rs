mod api;
mod event;
mod ui;

use event::{Config, Event, Events};
use log4rs;
use std::{error::Error, io};
use termion::{input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::{backend::TermionBackend, Terminal};
use ui::app::App;

fn main() -> Result<(), Box<dyn Error>> {
  // -- init start -- //
  // init log
  log4rs::init_file("log4rs.yaml", Default::default()).unwrap();

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

  // app init
  let mut app = App::new();
  // -- init end -- //

  loop {
    terminal.draw(|f| app.draw(f))?;

    match events.next()? {
      Event::Input(key) => app.on_key_event(key),
      Event::Tick => app.on_tick(),
    }
    if app.should_quit {
      break;
    }
  }

  Ok(())
}
