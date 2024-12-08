use core::error;

use reqwest::{
    self,
    header::{self, InvalidHeaderValue},
};
use thiserror::Error as ThisError;

#[derive(ThisError, Debug)]
pub enum SGClientErr {
    #[error("HTTP Error: {0}")]
    reqwestError(#[from] reqwest::Error),

    #[error("Invalid Header Value: {0}")]
    InvalidHeader(#[from] InvalidHeaderValue),

    #[error("Invalid Content Value: {0}")]
    SerlizationError(#[from] serde_json::Error),
}

pub type SGClienResult<T> = Result<T, SGClientErr>;
