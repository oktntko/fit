use git2::{
  Branch, BranchType, Commit, Config, Cred, CredentialType, Error, ErrorCode, FetchOptions,
  MergeOptions, PushOptions, RemoteCallbacks, Sort, Status, StatusOptions,
};
pub use git2::{Oid, Repository};
use log::debug;

pub struct Git {
  pub repo: Repository,
  // pub head_message: String,
  // pub head_hash: String,
  // pub branch_name: Option<String>,
  // pub upstream: Option<String>,
  // pub config: Config,
}

#[derive(Debug)]
pub struct FitStatus {
  pub status: Status,
  pub path: String,
  pub file_name: String,
}

impl Git {
  pub fn new() -> Git {
    let repo = Repository::discover(".").unwrap();
    debug!("state {:?}", repo.state());

    Git { repo }
  }

  pub fn status(&self) -> Vec<FitStatus> {
    let mut options = StatusOptions::new();
    options.include_untracked(true);
    options.include_ignored(false);

    self
      .repo
      .statuses(Some(&mut options))
      .unwrap()
      .iter()
      .map(|e| FitStatus {
        status: e.status(),
        path: e.path().unwrap().to_string(),
        file_name: e.path().unwrap().to_string(),
      })
      .collect()
  }
}
