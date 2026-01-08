from benchtool.BenchTool import BenchTool, Entry
from benchtool.Types import BuildConfig, Config, LogLevel, ReplaceLevel, TrialArgs

import json
import os
import re
import subprocess
import ctypes
import platform
import random

STRATEGIES_DIR = 'lib/Strategies'
IMPL_PATH = 'lib/'
SPEC_PATH = 'lib/spec.ml'

class OCaml(BenchTool):

    def __init__(self, results: str, seed: int, log_level: LogLevel = LogLevel.DEBUG, replace_level: ReplaceLevel = ReplaceLevel.REPLACE):
        super().__init__(
            Config(start='(*',
                   end='*)',
                   ext='.ml',
                   path='workloads/OCaml',
                   ignore='nothing',
                   strategies=STRATEGIES_DIR,
                   impl_path=IMPL_PATH,
                   spec_path=SPEC_PATH), results, log_level, replace_level)
        self.seed = seed  # Store the passed-in seed
        
    def all_properties(self, workload: Entry) -> list[Entry]:
        spec = os.path.join(workload.path, self._config.spec_path)
        with open(spec) as f:
             contents = f.read()
             regex = re.compile(r'prop_[^\s]*')
             matches = regex.findall(contents)
             return list(dict.fromkeys(matches))

    def _build(self, cfg: BuildConfig):
        with self._change_dir(cfg.path):
            self._shell_command(['dune', 'build'])

    def _run_trial(self, workload_path: str, params: TrialArgs):
        def reformat(filename):
            if filename.endswith('.json'):
                new_filename = os.path.splitext(filename)[0] + '.txt'
                os.rename(filename, new_filename)

        with self._change_dir(workload_path):
            self._log(f"Running trial for workload={params.workload} using seed={self.seed}", LogLevel.DEBUG)  # Log before executing

            for _ in range(params.trials):
                cmd = ['./_build/default/bin/main.exe', params.framework, params.property, params.strategy, params.file, str(self.seed)]
                self._shell_command(cmd)
            reformat(params.file)

    def _preprocess(self, workload: Entry) -> None:
        pass
