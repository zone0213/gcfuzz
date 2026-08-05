// @ts-nocheck
import { hilog } from '@kit.PerformanceAnalysisKit';
interface ArkTsIndexAccess {
    loadField(index: number): Object | null;
    storeField(index: number, value: Object | null): void;
}

class ArkTsArrayBox implements ArkTsIndexAccess {
    private values: Array<Object | null>;
    constructor(size: number, seed: Object | null) {
        const len = size > 0 ? size : 1;
        this.values = new Array<Object | null>(len).fill(null);
        if (len > 0) { this.values[0] = seed; }
    }
    loadField(index: number): Object | null {
        return this.values[index % this.values.length];
    }
    storeField(index: number, value: Object | null): void {
        this.values[index % this.values.length] = value;
    }
}

function anyToInt(value: Object | null): number {
    if (typeof value === "number") { return value; }
    if (typeof value === "boolean") { return value ? 1 : 0; }
    return 0;
}

function anyToBoolean(value: Object | null): boolean {
    if (typeof value === "boolean") { return value; }
    if (typeof value === "number") { return value !== 0; }
    return false;
}

// Runtime-varying condition for structured Fragment `If` wrappers: alternates on each call so
// both branches execute across the main-loop iterations. ArkTS cases are single-threaded, so
// a plain module-level flag suffices (no CAS needed, unlike PureKotlin's AtomicBoolean).
let branchState: boolean = false;
function branchDecision(): boolean {
    branchState = !branchState;
    return branchState;
}

class FuzzControlException extends Error {
    payload: Object | null;
    constructor(payload: Object | null) {
        super("FuzzControlException");
        this.payload = payload;
    }
}

let terminationRequested: boolean = false;
const startTimeMs: number = Date.now();
const GC_PRESSURE: number = 4096;
let pressureSink: Array<Object | null> = new Array<Object | null>(GC_PRESSURE).fill(null);

function shouldTerminate(): boolean {
    if (terminationRequested) { return true; }
    if ((Date.now() - startTimeMs) <= 30000) { return false; }
    terminationRequested = true;
    return true;
}

// ArkTools.hintGC() is the official ArkTS GC trigger (debug-only, non-forcing: VM decides
    // whether a full GC is appropriate — e.g. background + low expected survival). Declare it
    // so the type-checker is happy; at runtime the VM exposes ArkTools on device. Wrapped in
    // try/catch so that if ArkTools is unavailable we fall back to allocation-pressure below
    // instead of crashing the case. See ArkTS GC doc.
declare class ArkTools { static hintGC(): void; }
function hintGc(): void {
    try { ArkTools.hintGC(); } catch (e) { /* ArkTools unavailable — fall back to pressure */ }
}

function tryGc(): void {
    // Prefer the official ArkTools.hintGC() (when available); then apply allocation pressure
    // as a guaranteed fallback so unreachable objects become collectible even if hintGC was
    // suppressed (sensitive scenario) or ArkTools is absent. FinalizationRegistry observes.
    hintGc();
    for (let i = 0; i < GC_PRESSURE; i++) {
        if (shouldTerminate()) { return; }
        pressureSink[i % GC_PRESSURE] = i;
    }
    pressureSink = new Array<Object | null>(GC_PRESSURE).fill(null);
}

function alloc(block: () => ArkTsIndexAccess | null): ArkTsIndexAccess | null {
    if (shouldTerminate()) { return null; }
    return block();
}

// ---- Best-effort reachability oracle (P5, DOWNGRADED from the pure-kotlin sample) ----
// ArkTS has no force-GC; DEAD assertions are best-effort. gcEpoch is bumped when a
// FinalizationRegistry callback fires, so DEAD checks can be gated behind "GC has plausibly
// run" to reduce false positives. ALIVE is deterministic. This cannot match the determinism
// of kotlin.native.runtime.GC.collect().
enum ReachabilityExpectation { ALIVE, DEAD }
let gcEpoch: number = 0;
const fr: FinalizationRegistry<Object> = new FinalizationRegistry((_held: Object) => { gcEpoch = gcEpoch + 1; });
function assertReachability(label: string, expectation: number, value: Object | null): void {
    if (expectation === ReachabilityExpectation.ALIVE) {
        if (value == null) { throw new Error("Reachability oracle failed [" + label + "]: expected alive"); }
    } else {
        // DEAD is best-effort: without force-GC the object may not yet be collected, so a
        // non-null value here is NOT treated as a hard failure (would drown in false positives).
        // Real GC bugs still surface as crashes/aborts from the runtime itself.
    }
}
function registerObservation(observationId: number, target: Object | null): void {
    if (target != null) { fr.register(target, target); }
}
let g0: Object | null = null
let g1: Object | null = null
class Class0 implements ArkTsIndexAccess{
    constructor(f0: Object | null, f1: Object | null, f2: Object | null, f3: Object | null, f4: Object | null, f5: Object | null, f6: Object | null, f7: Object | null, f8: Object | null, f9: Object | null, f10: Object | null, f11: Object | null, f12: Object | null, f13: Object | null)
    {
        this.f0 = f0 == null ? null : new WeakRef<Object>(f0)
        this.f1 = anyToInt(f1)
        this.f2 = f2 == null ? null : new WeakRef<Object>(f2)
        this.f3 = f3
        this.f4 = anyToInt(f4)
        this.f5 = f5
        this.f6 = f6
        this.f7 = f7
        this.f8 = f8
        this.f9 = f9
        this.f10 = f10
        this.f11 = f11
        this.f12 = f12
        this.f13 = anyToInt(f13)
    }
    f0: WeakRef<Object> | null = null
    f1: number = anyToInt(null)
    f2: WeakRef<Object> | null = null
    f3: Object | null = null
    f4: number = anyToInt(null)
    f5: Object | null = null
    f6: Object | null = null
    f7: Object | null = null
    f8: Object | null = null
    f9: Object | null = null
    f10: Object | null = null
    f11: Object | null = null
    f12: Object | null = null
    f13: number = anyToInt(null)
    loadField(index: number): Object | null{
        switch (index % 14){
            case 0: return this.f0?.deref() ?? null;
            case 1: return this.f1;
            case 2: return this.f2?.deref() ?? null;
            case 3: return this.f3;
            case 4: return this.f4;
            case 5: return this.f5;
            case 6: return this.f6;
            case 7: return this.f7;
            case 8: return this.f8;
            case 9: return this.f9;
            case 10: return this.f10;
            case 11: return this.f11;
            case 12: return this.f12;
            case 13: return this.f13;
            default: return null;
        }
    }
    storeField(index: number, value: Object | null): void{
        switch (index % 14){
            case 0: this.f0 = value == null ? null : new WeakRef<Object>(value); break;
            case 1: this.f1 = anyToInt(value); break;
            case 2: this.f2 = value == null ? null : new WeakRef<Object>(value); break;
            case 3: this.f3 = value; break;
            case 4: this.f4 = anyToInt(value); break;
            case 5: this.f5 = value; break;
            case 6: this.f6 = value; break;
            case 7: this.f7 = value; break;
            case 8: this.f8 = value; break;
            case 9: this.f9 = value; break;
            case 10: this.f10 = value; break;
            case 11: this.f11 = value; break;
            case 12: this.f12 = value; break;
            case 13: this.f13 = anyToInt(value); break;
            default: break;
        }
    }
}

class Class1 implements ArkTsIndexAccess{
    constructor(f0: Object | null, f1: Object | null, f2: Object | null, f3: Object | null, f4: Object | null)
    {
        this.f0 = f0 == null ? null : new WeakRef<Object>(f0)
        this.f1 = f1
        this.f2 = f2 == null ? null : new WeakRef<Object>(f2)
        this.f3 = f3
        this.f4 = anyToInt(f4)
    }
    f0: WeakRef<Object> | null = null
    f1: Object | null = null
    f2: WeakRef<Object> | null = null
    f3: Object | null = null
    f4: number = anyToInt(null)
    loadField(index: number): Object | null{
        switch (index % 5){
            case 0: return this.f0?.deref() ?? null;
            case 1: return this.f1;
            case 2: return this.f2?.deref() ?? null;
            case 3: return this.f3;
            case 4: return this.f4;
            default: return null;
        }
    }
    storeField(index: number, value: Object | null): void{
        switch (index % 5){
            case 0: this.f0 = value == null ? null : new WeakRef<Object>(value); break;
            case 1: this.f1 = value; break;
            case 2: this.f2 = value == null ? null : new WeakRef<Object>(value); break;
            case 3: this.f3 = value; break;
            case 4: this.f4 = anyToInt(value); break;
            default: break;
        }
    }
}

class Class2 implements ArkTsIndexAccess{
    constructor(f0: Object | null, f1: Object | null)
    {
        this.f0 = f0
        this.f1 = f1 == null ? null : new WeakRef<Object>(f1)
    }
    f0: Object | null = null
    f1: WeakRef<Object> | null = null
    loadField(index: number): Object | null{
        switch (index % 2){
            case 0: return this.f0;
            case 1: return this.f1?.deref() ?? null;
            default: return null;
        }
    }
    storeField(index: number, value: Object | null): void{
        switch (index % 2){
            case 0: this.f0 = value; break;
            case 1: this.f1 = value == null ? null : new WeakRef<Object>(value); break;
            default: break;
        }
    }
}

function fun0(l0: Object | null, l1: Object | null, l2: Object | null): Object | null{
    g0 = l0
    let l3: ArkTsIndexAccess | null = alloc(() => { return new Class2(g1, g0); })
    g1 = g1
    let l4: ArkTsIndexAccess | null = alloc(() => { return new Class0(l2, null, null, null, null, null, null, null, null, null, null, null, null, null); })
    l3?.storeField(1, l0)
    let l5: ArkTsIndexAccess | null = alloc(() => { return new Class0(null, l4?.loadField(4), null, null, null, null, null, null, null, null, null, null, null, null); })
    tryGc()
    let l6: ArkTsIndexAccess | null = alloc(() => { return new Class0(g1, null, null, null, null, null, null, null, null, null, null, null, null, null); })
    for (let i = 0; i < 64; i++){
        alloc(() => { return new Class0(null, null, null, null, null, null, null, null, null, null, null, null, null, null); })
    }
    let l7: ArkTsIndexAccess | null = alloc(() => { return new Class0(g0, l4?.loadField(5), null, null, null, null, null, null, null, null, null, null, null, null); })
    g0 = g0
    return null
}

function fun1(l0: Object | null, l1: Object | null): Object | null{
    g1 = g1
    let l2: ArkTsIndexAccess | null = alloc(() => { return new Class0(l1, g0, l1, l0, null, null, null, null, null, null, null, null, null, null); })
    tryGc()
    g0
    let l4: ArkTsIndexAccess | null = alloc(() => { return new Class0(null, null, null, null, null, null, null, null, null, null, null, null, null, null); })
    tryGc()
    g0
    tryGc()
    let l6: ArkTsIndexAccess | null = alloc(() => { return new Class1(null, l4, null, l4, null); })
    g1 = l4?.loadField(10)
    tryGc()
    for (let i = 0; i < 44; i++){
        alloc(() => { return new Class1(null, null, null, null, null); })
    }
    let l7: ArkTsIndexAccess | null = alloc(() => { return new Class2(null, l6); })
    let l8: ArkTsIndexAccess | null = alloc(() => { return new Class2(l7?.loadField(0), null); })
    g0
    g1 = l2?.loadField(11)
    l6 = l8?.loadField(1)
    let l10: ArkTsIndexAccess | null = alloc(() => { return new Class1(g1, g1, null, null, null); })
    let l11: ArkTsIndexAccess | null = alloc(() => { return new Class2(l1, g1); })
    l11?.loadField(1)?.loadField(195)?.loadField(145)?.loadField(114)
    tryGc()
    let l13: ArkTsIndexAccess | null = alloc(() => { return new Class0(l2?.loadField(9), g0, g1, null, null, null, null, null, null, null, null, null, null, null); })
    return null
}


function mainBodyImpl(): Object | null{
    let l0: ArkTsIndexAccess | null = alloc(() => { return new Class1(null, null, null, null, null); })
    let l1: ArkTsIndexAccess | null = alloc(() => { return new Class0(null, null, null, null, null, null, null, null, null, null, null, null, null, null); })
    let l2: ArkTsIndexAccess | null = alloc(() => { return new Class1(null, null, null, null, null); })
    l0?.loadField(419581855)?.storeField(906175633, l1)
    g0 = l0
    l2 = g0?.loadField(419581855)?.loadField(906175633)
    l0?.loadField(419581855)?.storeField(906175633, null)
    g0 = null
    tryGc()
    l2
    let l3: ArkTsIndexAccess | null = alloc(() => { return new Class0(g0, l1, null, null, null, null, null, null, null, null, null, null, null, null); })
    l0 = g0
    tryGc()
    let l4: ArkTsIndexAccess | null = alloc(() => { return new Class2(null, null); })
    l3?.storeField(1, g1)
    let l5: ArkTsIndexAccess | null = alloc(() => { return new Class1(null, null, null, l4, null); })
    return null
}

export function main(): void{
    for (let i = 0; i < 20000; i++){
        if (shouldTerminate()) return
        mainBodyImpl()
    }
    terminationRequested = true
    tryGc()
}

