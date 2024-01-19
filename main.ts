#!/usr/bin/env -S deno run -A
import { parseArgs } from "https://deno.land/std@0.212.0/cli/mod.ts";
import { join } from "https://deno.land/std@0.212.0/path/join.ts";

// var
// PaperMCのapiのurl
const api_url = "https://api.papermc.io/v2/projects/";
// 実行ファイルのディレクトリ
const cur_dir = Deno.realPathSync(new URL(".", import.meta.url).pathname);

// config
type Config = {
  name: string;
  version: string;
  build?: number;
  memory?: string;
  timer?: number; // min
};

const defaultConfig: Config = {
  name: "paper",
  version: "latest",
  memory: "2G",
  timer: 720,
};

// function

// PaperMCのapiを叩いて、JSONを取得する
async function getapi(url: string) {
  const res = await fetch(url);
  const json = await res.json();
  return json;
}

// 最新のビルドを取得する
async function get_latest_build(config: Config) {
  const resp_product = await getapi(api_url + config.name);
  if (!resp_product.project_id.includes(config.name)) {
    console.log("name error");
    Deno.exit(1);
  }
  const versions = resp_product.versions;

  if (config.version === "latest") {
    config.version = versions[versions.length - 1];
  } else {
    if (!versions.includes(config.version)) {
      console.log("version error");
      Deno.exit(1);
    }
  }
  const url_build = api_url + config.name + "/versions/" + config.version;
  const resp_build = await getapi(url_build);
  if (resp_build.error) {
    console.log("build error");
    Deno.exit(1);
  }
  const builds = resp_build.builds;
  config.build = builds[builds.length - 1];
}

// paper productをダウンロードする
async function download_product(config: Config) {
  // get latest build
  await get_latest_build(config);

  const url = api_url + config.name + "/versions/" + config.version +
    "/builds/" + config.build + "/downloads/" + config.name + "-" +
    config.version + "-" + config.build + ".jar";
  const res = await fetch(url);
  const blob = await res.blob();
  const file = await Deno.create(
    config.name + "-" + config.version + "-" + config.build + ".jar",
  );
  // todo: progress bar
  // todo: deno.writeAllの代わりに、streamを使う
  await Deno.writeAll(file, new Uint8Array(await blob.arrayBuffer()));
  
  file.close();
}

// run server
async function run_server(config: Config) {
  const jar_file = config.name + "-" + config.version + "-" + config.build +
    ".jar";
  const jar_path = join(Deno.cwd(), jar_file);

  // ファイルが存在するか確認
  if (!(await Deno.stat(jar_path)).isFile) {
    console.log("file not found");
    Deno.exit(1);
  }
  // java options
  const java_options = [
    "-Xmx" + config.memory,
    "-Xms" + config.memory,
    "-jar",
    jar_path,
    "nogui",
  ];
  // java command
  const cmd = new Deno.Command(
    "java",
    {
      args: java_options,
      cwd: cur_dir,
      stdin: "piped",
      stdout: "piped",
      stderr: "piped",
    },
  );
  // java process
  const process = cmd.spawn();

  // java processのstdoutを表示
  readStream(process.stdout);
  // java processのstderrを表示
  readStream(process.stderr);

  // java processにコマンドを送信
  const timer_min = (config.timer ?? 0) * 60 * 1000;
  console.log("server stop after " + config.timer + " min.");
  const stop_timer = setTimeout(async () => {
    await writeStream(process.stdin, "stop\n");
  }, timer_min);
  
  console.log("server start.");

  // java processの終了を待つ
  const status = await process.status;
  console.log(status);
  clearTimeout(stop_timer);
}

// ReadableStreamを変換、表示
async function readStream(stream: ReadableStream) {
  const reader = stream.getReader();
  const decoder = new TextDecoder();
  while (true) {
    const { done, value } = await reader.read();
    if (done) {
      break;
    }
    if (value) {
      const text = decoder.decode(value);
      console.log(text);
    }
  }
}

// WritableStreamに書き込む
async function writeStream(stream: WritableStream<Uint8Array>, text: string) {
  const writer = stream.getWriter();
  const encoder = new TextEncoder();
  console.log(text);
  await writer.write(encoder.encode(text));
}

// main
if (import.meta.main) {
  const parsedArgs = parseArgs(Deno.args);
  const config: Config = {
    name: parsedArgs.name ?? defaultConfig.name,
    version: parsedArgs.version ?? defaultConfig.version,
    memory: parsedArgs.memory ?? defaultConfig.memory,
    timer: parsedArgs.timer ?? defaultConfig.timer,
  };

  // download
  await download_product(config);

  // run server
  while(true){
    await run_server(config);
  }
}
