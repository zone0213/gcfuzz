// Wrapper to run a gc-fuzz generated case inside the hap runner.
// Calls the case's exported main(), reports start/done/terminated via hilog.
import { hilog } from '@kit.PerformanceAnalysisKit';
import { main } from './FuzzCase';

const DOMAIN = 0xFF00;
const TAG = 'gcfuzz';

export async function runFuzzCase(): Promise<string> {
    hilog.info(DOMAIN, TAG, 'fuzz-case-start');
    const started = Date.now();
    try {
        // main() runs the GC stress loop with a soft-timeout (shouldTerminate).
        // It is sync but bounded; await a microtask tick to let the UI thread breathe.
        await Promise.resolve();
        main();
        const elapsed = Date.now() - started;
        hilog.info(DOMAIN, TAG, 'fuzz-case-done');
        return `fuzz-case-done in ${elapsed}ms`;
    } catch (e) {
        const elapsed = Date.now() - started;
        hilog.error(DOMAIN, TAG, 'fuzz-terminated: %{public}s', String(e));
        return `fuzz-terminated: ${String(e)} (${elapsed}ms)`;
    }
}
