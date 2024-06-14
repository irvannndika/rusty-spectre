FROM ubuntu:focal-20240530

RUN apt install curl git build-essential libssl-dev pkg-config 
RUN apt install protobuf-compiler libprotobuf-dev #Required for gRPC
RUN apt-get install clang-format clang-tidy \
clang-tools clang clangd libc++-dev \
libc++1 libc++abi-dev libc++abi1 \
libclang-dev libclang1 liblldb-dev \
libllvm-ocaml-dev libomp-dev libomp5 \
lld lldb llvm-dev llvm-runtime \
llvm python3-clang

FROM FROM rust:bookworm AS builder

WORKDIR $HOME
COPY . .
RUN cargo build --release
RUN cargo install wasm-pack
RUN rustup target add wasm32-unknown-unknown
RUN git clone https://github.com/irvannndika/rusty-spectre
RUN cd rusty-spectre
# Final run stage
FROM debian:bookworm-slim AS runner

WORKDIR /app
COPY --from=builder /$HOME/target/release/rusty-spectre /$HOME/rusty-spectre
CMD ["/$HOME/rusty-spectre"]
