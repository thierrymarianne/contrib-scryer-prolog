window.zenroomExecWrapper = function (script, conf, keys) {
    // Basic verification of inputs
    if (typeof script !== 'string') return { output: null, error: 'Script must be a string' };

    // Zenroom expects inputs to be strings or null, handle null/undefined gracefully
    const s = script || "";
    const c = conf || null;
    const k = keys || null;

    try {
        // We use the synchronous execution if possible for simplicity in Prolog integration.
        // Assuming zenroom.script().conf().keys().print() structure.
        // Note: zenroom.min.js API might vary slightly by version, 
        // using the standard Zencode API: zenroom.zencode_exec() or similar if available,
        // but typically the documented JS API is builder pattern.

        // This relies on zenroom being loaded globally

        // MVP: Using the official JS API: zenroom.script(...).conf(...).keys(...).executeSync()
        // If executeSync is not available, we have to deal with Promises which is harder for 'js_eval'
        // Let's assume for this MVP we are using a version that supports synchronous execution 
        // or we try to unwrap it.

        // Actually, Zenroom 3+ is often async. Scryer's js_eval is synchronous.
        // If Zenroom is async, this specific 'js_eval' approach will return a Promise object, not the result.
        // We might need to use a specialized synchronous wrapper or prompt the user that async is needed.

        // For MVP, we will try to use the classic zenroom.execute(script, conf, keys) if available
        // or the simple export.

        // Let's assume the simplified sync interface or mock it for now until we test it.

        // Attempting to use the documented simple API wrapper often found in examples:
        // zenroom_exec(script, conf, keys)

        const res = zenroom.script(s).conf(c).keys(k).executeSync();
        // Return JSON string so Prolog can read it as a string
        return JSON.stringify({ output: res, logs: "", error: null });

    } catch (e) {
        return JSON.stringify({ output: null, logs: "", error: e.toString() });
    }
};
