FROM rust:1.89-bookworm

ENV CARGO_HOME=/usr/local/cargo
ENV CARGO_TARGET_DIR=/usr/local/cargo/target

COPY . /app/rsealpack/src
RUN mkdir /app/rsealpack/src/src && cp /app/rsealpack/src/dummy.rs /app/rsealpack/src/src/main.rs
RUN sed -i 's/rsealpacked/rsealpacked_dummy/g' /app/rsealpack/src/Cargo.toml
RUN cd /app/rsealpack/src && cargo build --release

RUN find $CARGO_TARGET_DIR -type f -exec chmod o+rw {} + -o -type d -exec chmod o+wx {} +
