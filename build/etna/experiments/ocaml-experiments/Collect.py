import argparse
import os
import multiprocessing
import time
from benchtool.OCaml import OCaml
from benchtool.Types import BuildConfig, ReplaceLevel, TrialConfig, PBTGenerator, LogLevel
from benchtool.Tasks import tasks

DEFAULT_DIR = 'oc3'
REPLACE = False

WORKLOADS = ['BST', 'RBT', 'STLC']
STRATEGIES : list[PBTGenerator] = [
    PBTGenerator('base', 'bespoke'),
    PBTGenerator('base', 'bespokeStaged'),
    PBTGenerator('base', 'bespokeStagedC'),
    PBTGenerator('base', 'bespokeStagedCSR'),
    PBTGenerator('base', 'bespokeSingle'),
    PBTGenerator('base', 'bespokeSingleStaged'),
    PBTGenerator('base', 'bespokeSingleStagedC'),
    PBTGenerator('base', 'bespokeSingleStagedCSR'),
    PBTGenerator('base', 'type'),
    PBTGenerator('base', 'staged'),
    PBTGenerator('base', 'stagedC'),
    PBTGenerator('base', 'stagedCSR'),
]

TRIALS = 1
TIMEOUT = 65

def collect(directory: str, workloads=WORKLOADS, strategies=STRATEGIES, seed=53503520):
    tool = OCaml(directory, seed, replace_level=ReplaceLevel.REPLACE if REPLACE else ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        if workload.name not in workloads:
            continue

        for variant in tool.all_variants(workload):
            if variant.name == 'base':
                continue

            run_trial = tool.apply_variant(workload, variant, BuildConfig(
                        path=workload.path,
                        clean=False,
                        build_common=False,
                        build_strategies=True,
                        build_fuzzers=False,
                        no_base=True,
                    ))

            for strategy in strategies:
                processes = []
                for property in tool.all_properties(workload):
                    if workload.name in ['BST',
                                         'RBT',
                                         'STLC']:
                        # this is a map from the properties to try to the strategies that should be excluded from testing this property because they're too slow.
                        props_to_run = dict(tasks[workload.name][variant.name])
                        property_name = property.split('_')[1]
                        if property_name not in props_to_run.keys():
                            continue
                        excluded_strats = props_to_run[property_name]
                        if strategy.strategy in excluded_strats: 
                            tool._log(f"Strategy {strategy.framework + strategy.strategy.capitalize()} excluded from run for {workload.name},{variant.name},{property}",LogLevel.INFO)
                            continue

                    cfg = TrialConfig(workload=workload,
                                        strategy=strategy.strategy,
                                        framework=strategy.framework,
                                        property=property,
                                        label=strategy.framework + strategy.strategy.capitalize(),
                                        trials=TRIALS,
                                        timeout=TIMEOUT,
                                        short_circuit=False)

                    p = multiprocessing.Process(
                        target=run_process_trial,
                        args=(run_trial, cfg, strategy.framework + strategy.strategy)
                    )
                    processes.append(p)
                    p.start()
                
                for p in processes:
                    p.join()
                tool._log(f"All trials for all properties for workload={workload.name}, variant={variant.name}, strategy={strategy.framework + strategy.strategy} completed",LogLevel.INFO)


def run_process_trial(trial_func, config, label):
    try:
        result = trial_func(config)
        return result
    except Exception as e:
        raise

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--workload', help='single workload to run')
    p.add_argument('--seed', type=int, help='random seed for trials', default=53503520)
    args = p.parse_args()
    
    dir = args.data if args.data else DEFAULT_DIR
    workloads = [args.workload] if args.workload else WORKLOADS
    seed = args.seed  # Store the seed

    results_path = f'{os.getcwd()}/{dir}'
    collect(results_path, workloads=workloads, seed=seed)
