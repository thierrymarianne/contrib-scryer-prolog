use crate::arena::*;
use crate::forms::*;
use crate::heap_iter::{stackful_preorder_iter, NonListElider};
use crate::machine::machine_state::*;
use crate::machine::*;
use crate::offset_table::*;
use crate::types::*;

use std::ops::{Deref, DerefMut};

use derive_more::*;
use fxhash::FxBuildHasher;
use indexmap::IndexSet;
use num_order::NumOrd;

impl MachineState {
    pub(crate) fn partial_string_to_pdl(&mut self, pstr_loc: usize, l: usize) {
        let (c, succ_cell) = self.heap.last_str_char_and_tail(pstr_loc);

        self.pdl.push(heap_loc_as_cell!(l + 1));
        self.pdl.push(succ_cell);

        self.pdl.push(heap_loc_as_cell!(l));
        self.pdl.push(char_as_cell!(c));
    }
}

pub(crate) trait Unifier: DerefMut<Target = MachineState> {
    fn unify_structure(&mut self, s1: usize, value: HeapCellValue) {
        // s1 is the value of a STR cell.
        let (n1, a1) = cell_as_atom_cell!(self.heap[s1]).get_name_and_arity();

        read_heap_cell!(value,
            (HeapCellValueTag::Str, s2) => {
                let (n2, a2) = cell_as_atom_cell!(self.heap[s2])
                    .get_name_and_arity();

                if n1 == n2 && a1 == a2 {
                    for idx in (0..a1).rev() {
                        self.pdl.push(heap_loc_as_cell!(s2+1+idx));
                        self.pdl.push(heap_loc_as_cell!(s1+1+idx));
                    }
                } else {
                    self.fail = true;
                }
            }
            (HeapCellValueTag::Lis, l2) => {
                if a1 == 2 && n1 == atom!(".") {
                    for idx in (0..2).rev() {
                        self.pdl.push(heap_loc_as_cell!(l2+1+idx));
                        self.pdl.push(heap_loc_as_cell!(s1+1+idx));
                    }
                } else {
                    self.fail = true;
                }
            }
            (HeapCellValueTag::Atom, (n2, a2)) => {
                self.fail = !(a1 == 0 && a2 == 0 && n1 == n2);
            }
            (HeapCellValueTag::AttrVar, h) => {
                Self::bind(self, Ref::attr_var(h), str_loc_as_cell!(s1));
            }
            (HeapCellValueTag::Var, h) => {
                Self::bind(self, Ref::heap_cell(h), str_loc_as_cell!(s1));
            }
            (HeapCellValueTag::StackVar, s) => {
                Self::bind(self, Ref::stack_cell(s), str_loc_as_cell!(s1));
            }
            _ => {
                self.fail = true;
            }
        );
    }

    fn unify_list(&mut self, l1: usize, value: HeapCellValue) {
        read_heap_cell!(value,
            (HeapCellValueTag::Lis, l2) => {
                for idx in (0..2).rev() {
                    self.pdl.push(heap_loc_as_cell!(l2 + idx));
                    self.pdl.push(heap_loc_as_cell!(l1 + idx));
                }
            }
            (HeapCellValueTag::Str, s2) => {
                let (n2, a2) = cell_as_atom_cell!(self.heap[s2])
                    .get_name_and_arity();

                if a2 == 2 && n2 == atom!(".") {
                    for idx in (0..2).rev() {
                        self.pdl.push(heap_loc_as_cell!(s2+1+idx));
                        self.pdl.push(heap_loc_as_cell!(l1+idx));
                    }
                } else {
                    self.fail = true;
                }
            }
            (HeapCellValueTag::PStrLoc, l) => {
                Self::unify_partial_string(self, l, list_loc_as_cell!(l1))
            }
            (HeapCellValueTag::AttrVar, h) => {
                Self::bind(self, Ref::attr_var(h), list_loc_as_cell!(l1));
            }
            (HeapCellValueTag::Var, h) => {
                Self::bind(self, Ref::heap_cell(h), list_loc_as_cell!(l1));
            }
            (HeapCellValueTag::StackVar, s) => {
                Self::bind(self, Ref::stack_cell(s), list_loc_as_cell!(l1));
            }
            _ => {
                self.fail = true;
            }
        );
    }

    fn unify_partial_string(&mut self, pstr_loc: usize, value: HeapCellValue) {
        if let Some(r) = value.as_var() {
            Self::bind(self, r, pstr_loc_as_cell!(pstr_loc));
            return;
        }

        let machine_st = self.deref_mut();

        read_heap_cell!(value,
            (HeapCellValueTag::Str, s) => {
                let (name, arity) = cell_as_atom_cell!(machine_st.heap[s])
                    .get_name_and_arity();

                if name == atom!(".") && arity == 2 {
                    machine_st.partial_string_to_pdl(pstr_loc, s+1);
                } else {
                    machine_st.fail = true;
                }
            }
            (HeapCellValueTag::Lis, l) => {
                machine_st.partial_string_to_pdl(pstr_loc, l);
            }
            (HeapCellValueTag::PStrLoc, other_pstr_loc) => {
                match machine_st.heap.compare_pstr_segments(pstr_loc, other_pstr_loc) {
                    PStrSegmentCmpResult::Continue(v1, v2) => {
                        machine_st.pdl.push(v1.offset_by(pstr_loc));
                        machine_st.pdl.push(v2.offset_by(other_pstr_loc));
                    }
                    _ => {
                        machine_st.fail = true;
                    }
                }
            }
            _ => {
                machine_st.fail = true;
            }
        );
    }

    fn unify_ginteger(&mut self, n: GInteger, value: HeapCellValue) {
        match n {
            GInteger::Integer(integer) => self.unify_big_int(integer, value),
            GInteger::Fixnum(fixnum) => self.unify_fixnum(fixnum, value),
        }
    }

    fn unify_atom(&mut self, atom: Atom, value: HeapCellValue) {
        read_heap_cell!(value,
            (HeapCellValueTag::Atom, (name, arity)) => {
                self.fail = !(arity == 0 && name == atom);
            }
            (HeapCellValueTag::Str, s) => {
                let (name, arity) = cell_as_atom_cell!(self.heap[s])
                    .get_name_and_arity();

                self.fail = !(arity == 0 && name == atom);
            }
            (HeapCellValueTag::AttrVar, h) => {
                Self::bind(self, Ref::attr_var(h), atom_as_cell!(atom));
            }
            (HeapCellValueTag::Var, h) => {
                Self::bind(self, Ref::heap_cell(h), atom_as_cell!(atom));
            }
            (HeapCellValueTag::StackVar, s) => {
                Self::bind(self, Ref::stack_cell(s), atom_as_cell!(atom));
            }
            _ => {
                self.fail = true;
            }
        );
    }

    fn unify_char(&mut self, c: char, value: HeapCellValue) {
        read_heap_cell!(value,
            (HeapCellValueTag::Atom, (name, arity)) => {
                if let Some(c2) = name.as_char() {
                    self.fail = !(c == c2 && arity == 0);
                } else {
                    self.fail = true;
                }
            }
            (HeapCellValueTag::Str, s) => {
                let (name, arity) = cell_as_atom_cell!(self.heap[s])
                    .get_name_and_arity();

                if let Some(c2) = name.as_char() {
                    self.fail = !(c == c2 && arity == 0);
                } else {
                    self.fail = true;
                }
            }
            (HeapCellValueTag::AttrVar, h) => {
                Self::bind(self, Ref::attr_var(h), char_as_cell!(c));
            }
            (HeapCellValueTag::Var, h) => {
                Self::bind(self, Ref::heap_cell(h), char_as_cell!(c));
            }
            (HeapCellValueTag::StackVar, s) => {
                Self::bind(self, Ref::stack_cell(s), char_as_cell!(c));
            }
            _ => {
                self.fail = true;
            }
        );
    }

    fn unify_fixnum(&mut self, n1: Fixnum, value: HeapCellValue) {
        if let Some(r) = value.as_var() {
            Self::bind(self, r, fixnum_as_cell!(n1));
            return;
        }

        let machine_st = self.deref();

        match Number::try_from((value, &machine_st.arena.f64_tbl)) {
            Ok(n2) => match n2 {
                Number::Fixnum(n2) if n1.get_num() == n2.get_num() => {}
                Number::Integer(n2) if (*n2).num_eq(&n1.get_num()) => {}
                Number::Rational(n2) if (*n2).num_eq(&Integer::from(n1.get_num())) => {}
                _ => {
                    self.fail = true;
                }
            },
            Err(_) => {
                self.fail = true;
            }
        }
    }

    fn unify_big_integer(&mut self, n1: TypedArenaPtr<Integer>, value: HeapCellValue) {
        if let Some(r) = value.as_var() {
            Self::bind(self, r, typed_arena_ptr_as_cell!(n1));
            return;
        }

        let machine_st = self.deref();

        match Number::try_from((value, &machine_st.arena.f64_tbl)) {
            Ok(n2) => match n2 {
                Number::Fixnum(n2) if (*n1).num_eq(&n2.get_num()) => {}
                Number::Integer(n2) if (*n1).num_eq(&*n2) => {}
                Number::Rational(n2) if (*n2).num_eq(&*n1) => {}
                _ => {
                    self.fail = true;
                }
            },
            Err(_) => {
                self.fail = true;
            }
        }
    }

    fn unify_big_rational(&mut self, n1: TypedArenaPtr<Rational>, value: HeapCellValue) {
        if let Some(r) = value.as_var() {
            Self::bind(self, r, typed_arena_ptr_as_cell!(n1));
            return;
        }

        let machine_st = self.deref_mut();

        match Number::try_from((value, &machine_st.arena.f64_tbl)) {
            Ok(n2) => match n2 {
                Number::Fixnum(n2) if (*n1).num_eq(&Integer::from(n2.get_num())) => {}
                Number::Integer(n2) if (*n1).num_eq(&*n2) => {}
                Number::Rational(n2) if n1 == n2 => {}
                _ => {
                    self.fail = true;
                }
            },
            Err(_) => {
                self.fail = true;
            }
        }
    }

    fn unify_f64(&mut self, f1: F64Offset, value: HeapCellValue) {
        if let Some(r) = value.as_var() {
            Self::bind(self, r, HeapCellValue::from(f1));
            return;
        }

        read_heap_cell!(value,
            (HeapCellValueTag::F64Offset, f2) => {
                let machine_st = self.deref_mut();

                let f1 = machine_st.arena.f64_tbl.get_entry(f1);
                let f2 = machine_st.arena.f64_tbl.get_entry(f2);

                self.fail = f1 != f2;
            }
            _ => {
                self.fail = true;
            }
        );
    }

    fn unify_constant(&mut self, ptr: UntypedArenaPtr, value: HeapCellValue) {
        // Defensive guard against a Cons-tagged heap cell whose lower
        // 61-bit payload does not actually encode a valid arena
        // pointer. Without this guard the next deref (the `ldr` that
        // reads the ArenaHeader word) takes a SIGSEGV and kills the
        // whole process.
        //
        // A real arena pointer cannot land in the first 64 KiB of the
        // virtual address space (that range is always either unmapped
        // or owned by the dynamic loader on the platforms scryer
        // supports), and it is always aligned to the ArenaHeader
        // layout. Anything else came from a writer that stamped
        // non-pointer bits into a Cons cell -- almost certainly a
        // bug elsewhere, but we would rather convert it into a
        // unification failure than tear the process down.
        let raw = ptr.get_ptr() as usize;

        // The alignment check below is a no-op: ConsPtr::as_ptr left-
        // shifts by NICHE_SHIFT = log2(align_of::<ArenaHeader>()), so the
        // reconstructed pointer is 8-aligned by construction. The
        // `< 0x10000` threshold also misses typical leak values (heap-
        // index-shaped payloads ~10^6-10^7 shift to ~10^7-10^8).
        //
        // Real arena pointers on 64-bit systems live in ASLR regions
        // (0x5555....., 0x7fff.....) -- always above 4 GiB. Anything below
        // 4 GiB is either an inlined-atom payload or a tag-cleared heap
        // reference -- in both cases re-interpreting as a Var pointing to
        // the unshifted index is the least-bad behaviour: it converts a
        // SIGSEGV into a graceful Prolog-level failure that catch/3 can
        // handle.
        #[cfg(target_pointer_width = "64")]
        const PLAUSIBLE_MIN: usize = 0x1_0000_0000;
        #[cfg(not(target_pointer_width = "64"))]
        const PLAUSIBLE_MIN: usize = 0x10000;

        if raw < PLAUSIBLE_MIN {
            let heap_index = raw >> ConsPtr::NICHE_SHIFT;
            let recovered_var = heap_loc_as_cell!(heap_index);
            self.pdl.push(value);
            self.pdl.push(recovered_var);
            return;
        }

        // Keep the alignment check for any other corruption mode.
        if raw % core::mem::align_of::<ArenaHeader>() != 0 {
            self.fail = true;
            return;
        }

        if let Some(ptr2) = value.to_untyped_arena_ptr() {
            if ptr.get_ptr() == ptr2.get_ptr() {
                return;
            }
        }

        match_untyped_arena_ptr!(ptr,
             (ArenaHeaderTag::Integer, int_ptr) => {
                 Self::unify_big_integer(self, int_ptr, value);
             }
             (ArenaHeaderTag::Rational, rat_ptr) => {
                 Self::unify_big_rational(self, rat_ptr, value);
             }
             (ArenaHeaderTag::Stream, stream) => {
                 read_heap_cell!(value,
                     (HeapCellValueTag::AttrVar | HeapCellValueTag::Var | HeapCellValueTag::StackVar) => {
                         Self::bind(self, value.as_var().unwrap(), untyped_arena_ptr_as_cell!(ptr));
                     }
                     (HeapCellValueTag::Atom, (name, arity)) => {
                         if arity > 0 {
                             self.fail = true;
                         } else {
                             let stream_options = stream.options();

                             if let Some(alias) = stream_options.get_alias() {
                                 self.fail = name != alias;
                             } else {
                                 self.fail = true;
                             }
                         }
                     }
                     _ => {
                         self.fail = true;
                     }
                 );
             }
             _ => {
                 if let Some(r) = value.as_var() {
                     Self::bind(self, r, untyped_arena_ptr_as_cell!(ptr));
                 } else {
                     self.fail = true;
                 }
             }
        );
    }

    fn unify_internal(&mut self) {
        let mut tabu_list = IndexSet::with_hasher(FxBuildHasher::default());

        while !(self.pdl.is_empty() || self.fail) {
            let s1 = self.pdl.pop().unwrap();
            let s1 = (self.deref() as &MachineState).deref(s1);

            let s2 = self.pdl.pop().unwrap();
            let s2 = (self.deref() as &MachineState).deref(s2);

            if s1 != s2 {
                let d1 = self.store(s1);
                let d2 = self.store(s2);

                read_heap_cell!(d1,
                    (HeapCellValueTag::AttrVar, h) => {
                        Self::bind(self, Ref::attr_var(h), d2);
                    }
                    (HeapCellValueTag::Var, h) => {
                        Self::bind(self, Ref::heap_cell(h), d2);
                    }
                    (HeapCellValueTag::StackVar, s) => {
                        Self::bind(self, Ref::stack_cell(s), d2);
                    }
                    (HeapCellValueTag::Atom, (name, arity)) => {
                        debug_assert_eq!(arity, 0);
                        Self::unify_atom(self, name, d2);
                    }
                    (HeapCellValueTag::Str, s1) => {
                        if tabu_list.contains(&(d1, d2)) {
                            continue;
                        }

                        Self::unify_structure(self, s1, d2);

                        if !self.fail {
                            let d2 = self.store(d2);
                            tabu_list.insert((d1, d2));
                        }
                    }
                    (HeapCellValueTag::Lis, l1) => {
                        if d2.is_ref() && tabu_list.contains(&(d1, d2)) {
                            continue;
                        }

                        Self::unify_list(self, l1, d2);

                        if !self.fail {
                            let d2 = self.store(d2);
                            tabu_list.insert((d1, d2));
                        }
                    }
                    (HeapCellValueTag::PStrLoc, l) => {
                        read_heap_cell!(d2,
                            (HeapCellValueTag::PStrLoc |
                             HeapCellValueTag::Lis |
                             HeapCellValueTag::Str) => {
                                if tabu_list.contains(&(d1, d2)) {
                                    continue;
                                }
                            }
                            (HeapCellValueTag::AttrVar |
                             HeapCellValueTag::Var |
                             HeapCellValueTag::StackVar) => {
                            }
                            _ => {
                                self.fail = true;
                                break;
                            }
                        );

                        Self::unify_partial_string(self, l, d2);

                        if !self.fail && !d2.is_constant() {
                            let d2 = self.store(d2);
                            tabu_list.insert((d1, d2));
                        }
                    }
                    (HeapCellValueTag::F64Offset, f1) => {
                        Self::unify_f64(self, f1, d2);
                    }
                    (HeapCellValueTag::Fixnum, n1) => {
                        Self::unify_fixnum(self, n1, d2);
                    }
                    (HeapCellValueTag::Cons, ptr_1) => {
                        Self::unify_constant(self, ptr_1, d2);
                    }
                    (HeapCellValueTag::CutPoint, n1) => {
                        Self::unify_fixnum(self, n1, d2);
                    }
                    _ => {
                        unreachable!();
                    }
                );
            }
        }
    }

    fn bind(&mut self, r: Ref, value: HeapCellValue);
}

#[inline]
fn bind_with_occurs_check<U: Unifier>(unifier: &mut U, r: Ref, value: HeapCellValue) -> bool {
    if let RefTag::StackCell = r.get_tag() {
        // local variable optimization -- r cannot occur in the
        // heap structure bound to value, so don't bother
        // traversing value.
        U::bind(unifier, r, value);
        return false;
    }

    let mut occurs_triggered = false;

    if !value.is_constant() {
        let machine_st: &mut MachineState = unifier.deref_mut();
        machine_st.heap[0] = value;

        for cell in
            stackful_preorder_iter::<NonListElider>(&mut machine_st.heap, &mut machine_st.stack, 0)
        {
            let cell = unmark_cell_bits!(cell);

            if let Some(inner_r) = cell.as_var() {
                if r == inner_r {
                    occurs_triggered = true;
                    break;
                }
            }
        }
    }

    if occurs_triggered {
        unifier.fail = true;
    } else {
        U::bind(unifier, r, value);
    }

    occurs_triggered
}

#[derive(Deref, DerefMut)]
#[deref(forward)]
pub(crate) struct DefaultUnifier<'a> {
    machine_st: &'a mut MachineState,
}

impl<'a> From<&'a mut MachineState> for DefaultUnifier<'a> {
    #[inline(always)]
    fn from(machine_st: &'a mut MachineState) -> Self {
        Self { machine_st }
    }
}

impl<'a> Unifier for DefaultUnifier<'a> {
    fn bind(&mut self, r: Ref, value: HeapCellValue) {
        self.machine_st.bind(r, value);
    }
}

pub(crate) struct CompositeUnifierForOccursCheck<U> {
    unifier: U,
}

impl<U: Unifier> Deref for CompositeUnifierForOccursCheck<U> {
    type Target = MachineState;

    #[inline(always)]
    fn deref(&self) -> &Self::Target {
        self.unifier.deref()
    }
}

impl<U: Unifier> DerefMut for CompositeUnifierForOccursCheck<U> {
    #[inline(always)]
    fn deref_mut(&mut self) -> &mut Self::Target {
        self.unifier.deref_mut()
    }
}

impl<U: Unifier> From<U> for CompositeUnifierForOccursCheck<U> {
    #[inline(always)]
    fn from(unifier: U) -> Self {
        Self { unifier }
    }
}

impl<U: Unifier> Unifier for CompositeUnifierForOccursCheck<U> {
    fn bind(&mut self, r: Ref, value: HeapCellValue) {
        bind_with_occurs_check(&mut self.unifier, r, value);
    }
}

pub(crate) struct CompositeUnifierForOccursCheckWithError<U: Unifier> {
    unifier: U,
}

impl<U: Unifier> Deref for CompositeUnifierForOccursCheckWithError<U> {
    type Target = MachineState;

    #[inline(always)]
    fn deref(&self) -> &Self::Target {
        self.unifier.deref()
    }
}

impl<U: Unifier> DerefMut for CompositeUnifierForOccursCheckWithError<U> {
    #[inline(always)]
    fn deref_mut(&mut self) -> &mut Self::Target {
        self.unifier.deref_mut()
    }
}

impl<U: Unifier> From<U> for CompositeUnifierForOccursCheckWithError<U> {
    #[inline(always)]
    fn from(unifier: U) -> Self {
        Self { unifier }
    }
}

impl<U: Unifier> Unifier for CompositeUnifierForOccursCheckWithError<U> {
    fn bind(&mut self, r: Ref, value: HeapCellValue) {
        if bind_with_occurs_check(&mut self.unifier, r, value) {
            let err = self.representation_error(RepFlag::Term);
            let stub = functor_stub(atom!("unify_with_occurs_check"), 2);
            let err = self.error_form(err, stub);

            self.throw_exception(err);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machine::machine_state::MachineState;

    /// Regression for the SIGSEGV reported against a Prolog worker
    /// using postgresql-prolog's extended-protocol wire client.
    ///
    /// A heap cell tagged `Cons` whose lower-61-bit payload is a
    /// small integer (the production crash carried `0x301c7`, a
    /// `weaving_status.ust_id` value) used to crash the process
    /// inside `unify_constant` when scryer dereferenced the payload
    /// as an `*const ArenaHeader`.
    ///
    /// The improved guard uses PLAUSIBLE_MIN (4 GiB on 64-bit) to
    /// detect bogus pointers. For a bogus Cons cell with 61-bit
    /// payload `p`, `get_ptr()` returns `p << NICHE_SHIFT` (always
    /// 8-aligned by construction, so an alignment check alone is a
    /// no-op). Any reconstructed pointer below 4 GiB is recovered:
    /// the guard divides it back by NICHE_SHIFT to get a heap index
    /// and retries unification as a Var reference, turning a SIGSEGV
    /// into a graceful Prolog-level outcome that catch/3 can handle.
    ///
    /// The test allocates two fresh unbound vars on top of whatever
    /// MachineState::new() already placed on the heap, then crafts a
    /// bogus Cons cell whose 61-bit payload equals the second var's
    /// heap index. After recovery the guard re-unifies the two vars;
    /// the whole cycle completes without crash and fail == false.
    #[test]
    fn unify_constant_recovers_bogus_arena_ptr_below_plausible_min() {
        let mut wam = MachineState::new();

        // The heap may already contain cells from machine initialisation.
        // Record the current top so we can append two fresh unbound vars.
        let base = wam.heap.cell_len();
        wam.heap
            .push_cell(heap_loc_as_cell!(base))
            .expect("heap grow");
        wam.heap
            .push_cell(heap_loc_as_cell!(base + 1))
            .expect("heap grow");

        let var_loc = base;

        // The 61-bit ConsPtr payload equals the heap index that
        // get_ptr() will reconstruct after left-shifting by NICHE_SHIFT:
        //   raw = payload << NICHE_SHIFT  →  heap_index = raw >> NICHE_SHIFT = payload
        // Choose payload = base + 1 so the recovery lands on the second
        // fresh var, well below PLAUSIBLE_MIN for any realistic heap size.
        let payload = (base + 1) as u64;
        let bogus_cons = HeapCellValue::build_with(HeapCellValueTag::Cons, payload);

        // PDL pops last-pushed first; push the var first so the bogus
        // Cons cell is popped as s1 and exercises the `Cons` arm.
        wam.pdl.push(heap_loc_as_cell!(var_loc));
        wam.pdl.push(bogus_cons);

        let mut unifier = DefaultUnifier::from(&mut wam);
        unifier.unify_internal();

        assert!(
            !wam.fail,
            "recovery must bind the vars and complete without fail \
             for a bogus Cons pointer below PLAUSIBLE_MIN"
        );
    }
}
