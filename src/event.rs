use log::{debug, error};
use std::io;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;
use termion::event::Key;
use termion::input::TermRead;

pub enum Event<I> {
  Input(I),
  Tick,
}

#[derive(Debug, Clone, Copy)]
pub struct Config {
  pub tick_rate: Duration,
}

impl Default for Config {
  fn default() -> Config {
    Config {
      tick_rate: Duration::from_millis(250),
    }
  }
}
/// A small event handler that wrap termion input and tick events. Each event
/// type is handled in its own thread and returned to a common `Receiver`
#[allow(dead_code)]
pub struct Events {
  rx: mpsc::Receiver<Event<Key>>,
  input_handle: thread::JoinHandle<()>,
  tick_handle: thread::JoinHandle<()>,
}

impl Events {
  pub fn new(config: Config) -> Events {
    debug!("config {:?}", config);
    // Senderと Receiverを作る
    let (tx, rx) = mpsc::channel();
    // input handle
    let input_handle = {
      let tx = tx.clone();
      thread::spawn(move || {
        let stdin = io::stdin();
        for evt in stdin.keys() {
          if let Ok(key) = evt {
            if let Err(err) = tx.send(Event::Input(key)) {
              error!("error! {}", err);
              return;
            }
          }
        }
      })
    };
    // tick handle
    let tick_handle = {
      let tx = tx.clone();
      thread::spawn(move || loop {
        if tx.send(Event::Tick).is_err() {
          error!("error!");
          break;
        }
        thread::sleep(config.tick_rate);
      })
    };
    // return
    Events {
      rx,
      input_handle,
      tick_handle,
    }
  }

  pub fn next(&self) -> Result<Event<Key>, mpsc::RecvError> {
    self.rx.recv()
  }
}
