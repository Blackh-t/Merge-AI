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
}

pub type SGClienResult<T> = Result<T, SGClientErr>;
