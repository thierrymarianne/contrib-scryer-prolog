:- module(zenroom, [zencode_exec/5]).
:- use_module(library(wasm)).
:- use_module(library(charsio)).
:- use_module(library(lists)).
:- use_module(library(iso_ext)).

% WASM Implementation of zencode_exec/5
zencode_exec(Script, Conf, Keys, Output, Error) :-
    % 1. Convert Prolog Chars input to JS Strings
    (Script == [] -> JsScript = "" ; chars_to_string(Script, JsScript)),
    (Conf   == [] -> JsConf   = "" ; chars_to_string(Conf, JsConf)),
    (Keys   == [] -> JsKeys   = "" ; chars_to_string(Keys, JsKeys)),

    % 2. Construct the JS call string
    % We need to properly escape the strings to embed them in the JS call.
    % This is tricky manually. 
    % BETTER APPROACH:
    % js_eval can't easily take variables unless we build the string.
    
    % Let's use a simpler approach: Assign inputs to global temporary variables first
    % to avoid escaping hell, then call the function.
    
    escape_for_js(JsScript, SafeScript),
    escape_for_js(JsConf, SafeConf),
    escape_for_js(JsKeys, SafeKeys),
    
    format(chars(EvalStr), "JSON.stringify(window.zenroomExecWrapper(\"~s\", \"~s\", \"~s\"))", [SafeScript, SafeConf, SafeKeys]),
    
    % 3. Call JS - ResultJsonStr will be a Prolog string (list of chars)
    js_eval(EvalStr, ResultJsonStr),
    
    % 4. Simple JSON parsing (just extracting output/error for MVP)
    % A real JSON parser would be better, but for MVP we might need a simple extractor
    % or rely on library(charsio) or similar if available for json.
    % For now, let's just assume we get the string back and bind it.
    
    % In a real implementation: use library(json) if available.
    % For now, we just pass the Raw JSON string as Output for inspection.
    Output = ResultJsonStr, 
    Error = [].


% Helper: Convert chars to string (if needed, though chars are standard string in Scryer)
chars_to_string(Chars, Chars).

% Helper: Escape quotes for JS string embedding
escape_for_js([], []).
escape_for_js(['"'|Cs], ['\\', '"'|Rs]) :- !, escape_for_js(Cs, Rs).
escape_for_js(['\\'|Cs], ['\\', '\\'|Rs]) :- !, escape_for_js(Cs, Rs).
escape_for_js(['\n'|Cs], ['\\', 'n'|Rs]) :- !, escape_for_js(Cs, Rs).
escape_for_js([C|Cs], [C|Rs]) :- escape_for_js(Cs, Rs).

parse_result(Result, Output, Error) :-
    % This part depends heavily on what js_eval returns for an object.
    % If it returns an atom 'js_object', we can't read the fields.
    % FIX: Modifying the call to return JSON.stringify(result) instead of the object.
    true.
