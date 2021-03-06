import analysis.real init.classical
-- instance coe_rat_real : has_coe rat real := ⟨of_rat⟩

-- example : has_coe int real := by apply_instance

-- instance coe_int_real : has_coe int real := ⟨of_rat ∘ rat.of_int⟩

-- example : has_coe int real := by apply_instance

-- instance coe_nat_real : has_coe nat real := ⟨of_rat ∘ rat.of_int ∘ int.of_nat⟩ 

-- example : right_cancel_semigroup ℝ := by apply_instance

lemma of_rat_lt_of_rat {q₁ q₂ : ℚ} : of_rat q₁ < of_rat q₂ ↔ q₁ < q₂ := 
begin
simp [lt_iff_le_and_ne, of_rat_le_of_rat]
end

-- Helpful simp lemmas for reals: thanks to Sebastian Ullrich
run_cmd mk_simp_attr `real_simps
attribute [real_simps] of_rat_zero of_rat_one of_rat_neg of_rat_add of_rat_sub of_rat_mul
attribute [real_simps] of_rat_inv of_rat_le_of_rat of_rat_lt_of_rat
@[real_simps] lemma of_rat_bit0 (a : ℚ) : bit0 (of_rat a) = of_rat (bit0 a) := of_rat_add
@[real_simps] lemma of_rat_bit1 (a : ℚ) : bit1 (of_rat a) = of_rat (bit1 a) :=
by simp [bit1, bit0, of_rat_add,of_rat_one]
@[real_simps] lemma of_rat_div {r₁ r₂ : ℚ} : of_rat r₁ / of_rat r₂ = of_rat (r₁ / r₂) :=
by simp [has_div.div, algebra.div] with real_simps

-- I don't understand this code; however it is the only way that I as
-- a muggle know how to access norm_num. Thanks to Mario Carneiro
namespace tactic
meta def eval_num_tac : tactic unit :=
do t ← target,
   (lhs, rhs) ← match_eq t,
   (new_lhs, pr1) ← norm_num lhs,
   (new_rhs, pr2) ← norm_num rhs,
   is_def_eq new_lhs new_rhs,
   `[exact eq.trans %%pr1 (eq.symm %%pr2)]
end tactic



-- variable α : Type

-- example : set α = (α → Prop) := rfl
/-
#print nonempty 
-- set_option pp.all true
noncomputable def floor_with_proof : ℝ → ℤ  := λ x, 
begin
--  have H2 : 0+x < 1+x, by 
--    apply add_lt_add_of_lt_of_le (zero_lt_one) (le_of_eq (rfl)),
--  have H3 : x < x+1, by simp [H2],
  let rat_in_interval := {q // x < of_rat q ∧ of_rat q < x + 1},
  have H : ∃ (q : ℚ), x < of_rat q ∧ of_rat q < x + 1,
  exact @exists_lt_of_rat_of_rat_gt x (x+1) (by simp [zero_lt_one]),
  have H2 : ∃ (s : rat_in_interval), true,
  simp [H],
  have H3 : nonempty rat_in_interval,
    apply exists.elim H2,
    intro a,
    intro Pa,
    constructor,
    exact a,
  have qHq : rat_in_interval := classical.choice (H3),
  cases qHq with q Hq,
  exact (if (x < rat.floor q) then rat.floor q - 1  else rat.floor q ),
end

-- theorems need classical logic
-- should it be 
-- theorem floor_le : ∀ x, floor x ≤ x
-- or
-- theorem floor_ge : ∀ x, x ≥ floor x
-- or any other combination of these ideas?
-- How many? One? Four?
noncomputable theorem floor_le (x : ℝ) : ↑(floor x) ≤ x :=
begin
unfold floor,
simp,

have n : ℤ := floor x,

admit,
end

-- should I prove floor + 1 or 1 + floor?
theorem lt_floor_add_one (x : ℝ) : x < 1 + floor x := sorry
-/
-- set_option pp.notation false
-- set_option pp.all true

-- #check le_of_lt
-- noncomputable example : preorder ℝ := by apply_instance

-- #print sub_lt_iff

-- #check @rat.cast_le

-- #check sub_lt

theorem floor_real_exists : ∀ (x : ℝ), ∃ (n : ℤ), ↑n ≤ x ∧ x < n+1 :=
begin
intro x,
have H : ∃ (q : ℚ), x < ↑q ∧ ↑q < x + 1,
  exact @exists_rat_btwn x (x+1) (by simp [zero_lt_one]),
cases H with q Hq,
cases classical.em (x < rat.floor q) with Hb Hs,
  exact ⟨rat.floor q - 1,
  begin
  split,
    simp [rat.floor_le q,Hq.right],
    suffices H7 : (↑q:real) ≤ x+1,
      exact calc (↑(rat.floor q):ℝ) = (↑((rat.floor q):ℚ):ℝ) : by simp
      ... ≤ (↑q:ℝ) : rat.cast_le.mpr (rat.floor_le q)
      ... ≤ x+1 : H7,
    exact le_of_lt Hq.right,
  simp,
  rw [←add_assoc],
  simp [Hb]
  end
  ⟩,

  exact ⟨rat.floor q,
    begin
    split,
      {
        have H : (x < ↑(rat.floor q)) ∨ (x ≥ ↑(rat.floor q)),
          exact lt_or_ge x ↑(rat.floor q),
        cases H with F T,
          exact false.elim (Hs F),
          exact T
      },
    {
      clear Hs,
      have H1 : x < ↑q,
        { exact Hq.left },
      clear Hq,
/-
      rw [←coe_rat_eq_of_rat] at H1,
      suffices H2 : x < ↑(rat.floor q) + ↑(1:ℤ),
        simp [H2],
      suffices H3 : q < ↑(((rat.floor q):ℤ):ℚ) + ↑(1:ℤ),
      exact lt_trans H1 _,-- (by rw [←rat.cast_add]), 
-/
      -- insanity starts here

      suffices H2 : q < ↑((rat.floor q)+(1:ℤ)),
        have H3 : ¬ (rat.floor q + 1 ≤ rat.floor q),
          intro H4,
          suffices H5 : rat.floor q < rat.floor q + 1,
            exact (lt_iff_not_ge (rat.floor q) ((rat.floor q)+1)).mp H5 H4,
        -- exact (lt_iff_not_ge q (((rat.floor q) + 1):int):rat).mpr,
        simp,
        tactic.swap,
        apply (lt_iff_not_ge q _).mpr,
        intro H2,
        have H3 : (rat.floor q) + 1 ≤ rat.floor q,
          exact rat.le_floor.mpr H2,
          have H4: (1:ℤ) > 0,
            exact int.one_pos,
          suffices H5 : (rat.floor q) + 1 > rat.floor q,
            exact (lt_iff_not_ge (rat.floor q) (rat.floor q + 1)).mp H5 H3,
            -- rw [add_comm (rat.floor q) (1:ℤ)],
            -- exact add_lt_add_left H4 (rat.floor q),add_zero (rat.floor q)],
            have H6 :rat.floor q + 0 < rat.floor q + 1,
            exact (add_lt_add_left H4 (rat.floor q)),
            exact @eq.subst _ (λ y, y < rat.floor q + 1) _ _ (add_zero (rat.floor q)) H6,
      clear H3,
      suffices H3 : of_rat q < ↑(rat.floor q) + 1,
        -- exact lt.trans H1 H3,
        exact calc x < ↑q : H1
        ... = of_rat q : coe_rat_eq_of_rat q
        ... < ↑(rat.floor q) + 1 : H3,
      clear H1,
      rw [←coe_rat_eq_of_rat],
      have H : (↑(rat.floor q):ℝ) + (1:ℝ) = (((rat.floor q):ℚ):ℝ) + (((1:ℤ):ℚ):ℝ),
        simp,
      rw [H,←rat.cast_add,rat.cast_lt,←int.cast_add],
      exact H2
    }
    end⟩
end

theorem square_cont_at_zero : ∀ (r:ℝ), r>0 → ∃ (eps:ℝ),(eps>0) ∧ eps^2<r :=
begin
intros r Hrgt0,
cases classical.em (r<1) with Hrl1 Hrnl1,
  have H : r^2<r,
    unfold pow_nat has_pow_nat.pow_nat monoid.pow,
    simp,
    exact calc r*r < r*1 : mul_lt_mul_of_pos_left Hrl1 Hrgt0
    ... = r : mul_one r,
  existsi r,
  exact ⟨Hrgt0,H⟩,
have Hrge1 : r ≥ 1,
  exact le_of_not_lt Hrnl1,
cases le_iff_eq_or_lt.mp Hrge1 with r1 rg1,
  existsi ((1/2):ℝ),
  split,
    suffices H : 0 < ((1/2):ℝ),
      exact H,
    simp with real_simps,
    exact dec_trivial,
  -- *TODO* 1/2 > 0 doesn't work!
  -- need of_rat_gt, not in realsimps
  rw [←r1],
  unfold pow_nat has_pow_nat.pow_nat monoid.pow,
  simp with real_simps,
  exact dec_trivial,
clear Hrnl1 Hrge1,
existsi (1:ℝ),
split,
  exact zero_lt_one,
unfold pow_nat has_pow_nat.pow_nat monoid.pow,
simp,
exact rg1
end

theorem exists_square_root (r:ℝ) (rnneg : r ≥ 0) : ∃ (q : ℝ), (q ≥ 0) ∧ q^2=r :=
begin
cases le_iff_eq_or_lt.mp rnneg with r0 rpos,
  rw [←r0],
  have H : (0:ℝ)≥ 0 ∧ (0:ℝ)^2 = 0,
  split,
  exact le_of_eq (by simp),
  unfold pow_nat has_pow_nat.pow_nat monoid.pow,
  simp,
  exact ⟨(0:ℝ),H⟩,
  clear rnneg,
let s := { x:ℝ | x^2 ≤ r},
have H0 : (0:ℝ) ∈ s,
  simp,
  unfold pow_nat has_pow_nat.pow_nat monoid.pow,
  simp,
  exact le_of_lt rpos,
have H1 : max r 1 ∈ upper_bounds s,
  cases classical.em (r ≤ 1) with rle1 rgt1,
    unfold upper_bounds,
    unfold set_of,
    intro t,
    intro Ht,
    suffices H : t ≤ 1,
      exact le_trans H (le_max_right r 1),
    have H : t^2 ≤ 1,
      exact le_trans Ht rle1,
    cases classical.em (t≤1) with tle1 tgt1,
      exact tle1,
    have H2: t > 1,
      exact lt_of_not_ge tgt1,
    exfalso,
    have H3 : t*t>1,
      exact calc 1<t : H2
      ... = t*1 : eq.symm (mul_one t)
      ... < t*t : mul_lt_mul_of_pos_left H2 (lt_trans zero_lt_one H2),
    unfold pow_nat has_pow_nat.pow_nat monoid.pow at H,
    simp at H,
    exact not_lt_of_ge H H3,

  have H : 1<r,
    exact lt_of_not_ge rgt1,
  unfold upper_bounds,
  unfold set_of,
  intro t,
  intro Ht,
  suffices H : t ≤ r,
    exact le_trans H (le_max_left r 1),
  cases classical.em (t≤r) with Hl Hg,
    exact Hl,
  have H1 : r<t,
    exact lt_of_not_ge Hg,
  have H2 : t^2 ≤ r,
    exact Ht,
  clear H0 Ht s Hg rgt1,
  exfalso,
  have H3 : 1<t,
    exact lt_trans H H1,
  have H4 : t^2 < t,
    exact lt_of_le_of_lt H2 H1,
  have H5 : t < t^2,
    exact calc t = 1*t : eq.symm (one_mul t)
    ... < t*t : mul_lt_mul_of_pos_right H3 (lt_trans zero_lt_one H3)
    ... = t^2 : by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp},
  have H6 : t < t,
    exact lt_trans H5 H4,
  have H7 : ¬ (t=t), 
    exact ne_of_lt H6,
  exact H7 (rfl),
have H : ∃ (x : ℝ), is_lub s x,
  exact exists_supremum_real H0 H1,
cases H with q Hq,
existsi q,
unfold is_lub at Hq,
unfold is_least at Hq,
split,
  exact Hq.left 0 H0,
have Hqge0 : 0 ≤ q,
  exact Hq.left 0 H0,
-- idea is to prove q^2=r by showing not < or >
-- first not <
have H2 : ¬ (q^2<r),
  intro Hq2r,
  have H2 : q ∈ upper_bounds s,
    exact Hq.left,
  clear Hq H0 H1,
  unfold upper_bounds at H2,
  have H3 : ∀ qe, q<qe → ¬(qe^2≤r),
    intro qe,
    intro qlqe,
    intro H4,
    have H5 : qe ≤ q,
      exact H2 qe H4,
    exact not_lt_of_ge H5 qlqe,
  have H4 : ∀ eps > 0,(q+eps)^2>r,
    intros eps Heps,
    exact lt_of_not_ge (H3 (q+eps) ((lt_add_iff_pos_right q).mpr Heps)),
  clear H3 H2 s,
  cases le_iff_eq_or_lt.mp Hqge0 with Hq0 Hqg0,
    cases (square_cont_at_zero r rpos) with eps Heps,
    specialize H4 eps,
    rw [←Hq0] at H4,
    simp at H4,
    have H3 : eps^2>r,
      exact H4 Heps.left,
    exact (lt_iff_not_ge r (eps^2)).mp H3 (le_of_lt Heps.right), 
  clear Hqge0,
  -- want eps such that 2*q*eps+eps^2 <= r-q^2
  -- so eps=min((r-q^2)/4q,thing-produced-by-square-cts-function)
  have H0 : (0:ℝ)<2, 
    simp with real_simps,
    exact dec_trivial,
  have H : 0<(r-q^2),
    exact sub_pos_of_lt Hq2r,
  have H2 : 0 < (r-q^2)/2,
    exact div_pos_of_pos_of_pos H H0,
  have H3 : 0 < (r-q^2)/2/(2*q),
    exact div_pos_of_pos_of_pos H2 (mul_pos H0 Hqg0),
  cases (square_cont_at_zero ((r-q^2)/2) H2) with e0 He0,
  let e1 := min ((r-q^2)/2/(2*q)) e0,
  have He1 : e1>0,
    exact lt_min H3 He0.left,
  specialize H4 e1, -- should be a contradiction
  have H1 : (q+e1)^2 > r,
    exact H4 He1,
  have H5 : e1 ≤ ((r-q^2)/2/(2*q)),
    exact (min_le_left ((r-q^2)/2/(2*q)) e0),
  have H6 : e1*e1<(r - q ^ 2) / 2,
    exact calc e1*e1 ≤ e0*e1 : mul_le_mul_of_nonneg_right (min_le_right ((r - q ^ 2) / 2 / (2 * q)) e0) (le_of_lt He1)
    ... ≤ e0*e0 : mul_le_mul_of_nonneg_left (min_le_right ((r - q ^ 2) / 2 / (2 * q)) e0) (le_of_lt He0.left )
    ... = e0^2 :  by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp}
    ... < (r-q^2)/2 : He0.right,
  have Hn1 : (q+e1)^2 < r,
    exact calc (q+e1)^2 = (q+e1)*(q+e1) : by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp}
    ... = q*q+2*q*e1+e1*e1 : by rw [mul_add,add_mul,add_mul,mul_comm e1 q,two_mul,add_mul,add_assoc,add_assoc,add_assoc]
    ... = q^2 + (2*q)*e1 + e1*e1 : by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp}
    ... ≤ q^2 + (2*q)*((r - q ^ 2) / 2 / (2 * q)) + e1*e1 : add_le_add_right (add_le_add_left ((mul_le_mul_left (mul_pos H0 Hqg0)).mpr H5) (q^2)) (e1*e1)
    ... < q^2 + (2*q)*((r - q ^ 2) / 2 / (2 * q)) + (r-q^2)/2 : add_lt_add_left H6 _
    ... = r : by rw [mul_comm,div_mul_eq_mul_div,mul_div_assoc,div_self (ne_of_gt (mul_pos H0 Hqg0)),mul_one,add_assoc,div_add_div_same,←two_mul,mul_comm,mul_div_assoc,div_self (ne_of_gt H0),mul_one,add_sub,add_comm,←add_sub,sub_self,add_zero], -- rw [mul_div_cancel'], -- nearly there
exact not_lt_of_ge (le_of_lt H1) Hn1,
-- now not >
have H3 : ¬ (q^2>r),
  intro Hq2r,
  have H3 : q ∈ lower_bounds (upper_bounds s),
    exact Hq.right,
  clear Hq H0 H1 H2,
  have Hqg0 : 0 < q,
    cases le_iff_eq_or_lt.mp Hqge0 with Hq0 H,
      tactic.swap,
      exact H,
    unfold pow_nat has_pow_nat.pow_nat monoid.pow at Hq2r,
    rw [←Hq0] at Hq2r,
    simp at Hq2r,
    exfalso,
    exact not_lt_of_ge (le_of_lt rpos) Hq2r,
  clear Hqge0,
  have H : ∀ (eps:ℝ), (eps > 0 ∧ eps < q) → (q-eps)^2 < r,
    unfold lower_bounds at H3,
    unfold set_of at H3,
    unfold has_mem.mem set.mem has_mem.mem at H3,
    intros eps Heps,
    have H : ¬ ((q-eps) ∈ (upper_bounds s)),
      intro H,
      have H2 : q ≤ q-eps,
        exact H3 (q-eps) H,
      rw [le_sub_iff_add_le] at H2,
      have Hf : q<q, 
        exact calc 
        q < eps+q : lt_add_of_pos_left q Heps.left
        ...   = q+eps : add_comm eps q
        ... ≤ q : H2, 
      have Hf2 : ¬ (q=q),
        exact ne_of_lt Hf,
      exact Hf2 (by simp),
    unfold upper_bounds at H,
    unfold has_mem.mem set.mem has_mem.mem set_of at H,
    have H2 : ∃ (b:ℝ), ¬ (s b → b ≤ q-eps),
      exact classical.not_forall.mp H, 
    cases H2 with b Hb,
    clear H,
    cases classical.em (s b) with Hsb Hsnb,
      tactic.swap,
      have Hnb : s b → b ≤ q - eps,
        intro Hsb,
        exfalso,
        exact Hsnb Hsb,
      exfalso,
      exact Hb Hnb,
    cases classical.em (b ≤ q - eps) with Hlt Hg,
      exfalso,
      exact Hb (λ _,Hlt),
    have Hh : q-eps < b,
      exact lt_of_not_ge Hg,
    clear Hg Hb,
    -- todo: (q-eps)>0, (q-eps)^2<b^2<=r, 
    have H0 : 0<q-eps,
      rw [lt_sub_iff,zero_add],exact Heps.right,
    unfold pow_nat has_pow_nat.pow_nat monoid.pow,
    exact calc (q-eps)*((q-eps)*1) = (q-eps)*(q-eps) : congr_arg (λ t, (q-eps)*t) (mul_one (q-eps))
    ... < (q-eps) * b : mul_lt_mul_of_pos_left Hh H0
    ... < b * b : mul_lt_mul_of_pos_right Hh (lt_trans H0 Hh)
    ... = b^2 : by { unfold pow_nat has_pow_nat.pow_nat monoid.pow, simp}
    ... ≤ r : Hsb,
  -- We now know (q-eps)^2<r for all eps>0, and q^2>r. Need a contradiction.
  -- Idea: (q^2-2*q*eps+eps^2)<r so 2q.eps-eps^2>q^2-r>0, 
  -- so we need to find eps such that 2q.eps-eps^2<(q^2-r)
  -- so set eps=min((q^2-r)/2q,q)
  have H0 : (0:ℝ)<2, 
    simp with real_simps,
    exact dec_trivial,
  have H1 : 0<(q^2-r),
    exact sub_pos_of_lt Hq2r,
  have H2 : 0 < (q/2),
    exact div_pos_of_pos_of_pos Hqg0 H0,
  have J1 : 0 < (q^2-r)/(2*q),
    exact div_pos_of_pos_of_pos H1 (mul_pos H0 Hqg0),
  let e1 := min ((q^2-r)/(2*q)) (q/2),
  have He1 : e1>0,
    exact lt_min J1 H2,
  specialize H e1, -- should be a contradiction
  have J0 : e1<q,
    exact calc e1 ≤ (q/2) : min_le_right ((q^2-r)/(2*q)) (q/2)
    ... = q*(1/2) : by rw [←mul_div_assoc,mul_one]
    ... < q*1 : mul_lt_mul_of_pos_left (by simp with real_simps;exact dec_trivial) Hqg0
    ... = q : by rw [mul_one],
  have H4 : (q-e1)^2 < r,
    exact H ⟨He1,J0⟩,
  have H5 : e1 ≤ ((q^2-r)/(2*q)),
    exact (min_le_left ((q^2-r)/(2*q)) (q/2)),
  have H6 : e1*e1>0,
    exact mul_pos He1 He1,
  have Hn1 : (q-e1)^2 > r,
    exact calc (q-e1)^2 = (q-e1)*(q-e1) : by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp}
    ... = q*q-2*q*e1+e1*e1 : by rw [mul_sub,sub_mul,sub_mul,mul_comm e1 q,two_mul,add_mul];simp
    ... = q^2 - (2*q)*e1 + e1*e1 : by {unfold pow_nat has_pow_nat.pow_nat monoid.pow,simp}
    ... > q^2 - (2*q)*e1         : lt_add_of_pos_right (q^2 -(2*q)*e1) H6
    ... ≥ q^2 - (2*q)*((q ^ 2 - r) / (2 * q)) : sub_le_sub (le_of_eq (eq.refl (q^2))) (mul_le_mul_of_nonneg_left H5 (le_of_lt (mul_pos H0 Hqg0))) -- lt_add_iff_pos_right  -- (add_le_add_left ((mul_le_mul_left (mul_pos H0 Hqg0)).mpr H5) (q^2)) (e1*e1)
    ... = r : by rw [←div_mul_eq_mul_div_comm,div_self (ne_of_gt (mul_pos H0 Hqg0)),one_mul];simp, --     ... = r : by rw [mul_comm,div_mul_eq_mul_div,mul_div_assoc,div_self (ne_of_gt (mul_pos H0 Hqg0)),mul_one,add_assoc,div_add_div_same,←two_mul,mul_comm,mul_div_assoc,div_self (ne_of_gt H0),mul_one,add_sub,add_comm,←add_sub,sub_self,add_zero], -- rw [mul_div_cancel'], -- nearly there

    exact not_lt_of_ge (le_of_lt (H ⟨He1,J0⟩)) Hn1,
  have H : q^2 ≤ r,
    exact le_of_not_lt H3,
  cases lt_or_eq_of_le H with Hlt Heq,
    exfalso,
    exact H2 Hlt,
  exact Heq
end

namespace M1F


lemma rat.zero_eq_int_zero (z : int) : ↑ z = (0:rat) → z = 0 :=
begin
simp [rat.mk_eq_zero,nat.one_pos,rat.coe_int_eq_mk]
end 

lemma rat.of_int_inj (z₁ z₂ : int) : (z₁ : rat) = (z₂ : rat) → z₁ = z₂ :=
begin
intro H12,
have H2 : ↑(z₁ - z₂) = (0:rat),
exact calc
↑(z₁ - z₂) = (↑z₁ - ↑z₂ : ℚ)  : by simp --  (rat.cast_sub z₁ z₂)
...               = (↑ z₂ - ↑ z₂:ℚ)  : by rw H12
... = (0 : rat) : by simp,
have H3 : z₁ - z₂ = 0,
exact rat.zero_eq_int_zero (z₁ -z₂) H2,
clear H12 H2,
exact sub_eq_zero.mp H3
end

lemma rational_half_not_an_integer : ¬ (∃ y : ℤ, 1/2 = (y:rat)) :=
begin
simp,
assume x:ℤ,
intro H,
unfold has_inv.inv at H, -- why does this become such an effort?
unfold division_ring.inv at H,
unfold field.inv at H,
unfold linear_ordered_field.inv at H,
unfold discrete_linear_ordered_field.inv at H,
unfold discrete_field.inv at H,
have H2 : ((2:rat)*rat.inv 2) = (2:rat)*x,
simp [H],
have H21 : (2:rat)≠ 0 := dec_trivial,
have H3 : (2:rat)*rat.inv 2 = (1:rat),
exact rat.mul_inv_cancel 2 H21,
have H4 : (1:rat) = (2:rat)*(x:rat),
exact H3 ▸ H2,
have H5 : ((((2:int)*x):int):rat)=((2:int):rat)*(x:rat),
simp [rat.cast_mul],
have H6 : ↑ ((2:int)*x) = (↑1:rat),
exact eq.trans H5 (eq.symm H4),
clear H H2 H21 H3 H4 H5,
have H7 : 2*x=1,
exact rat.of_int_inj (2*x) 1 H6,
clear H6,
have H8 : (2*x) % 2 = 0,
simp [@int.add_mul_mod_self 0],
have H9 : (1:int) % 2 = 0,
apply @eq.subst ℤ  (λ t, t%2 =0) _ _ H7 H8,
have H10 : (1:int) % 2 ≠ 0,
exact dec_trivial,
contradiction,
end

lemma real_half_not_an_integer : ¬ (∃ y : ℤ, of_rat (1/2) = of_rat(y)) :=
begin
assume H : (∃ y : ℤ, of_rat (1/2) = of_rat(y)),
have H2 : (∃ y : ℤ , (1:rat)/2 = (y:rat)),
apply exists.elim H,
intro a,
intro H3,
existsi a,
exact (@of_rat_inj (1/2) (a:rat)).mp H3,
exact rational_half_not_an_integer H2,
end

-- #check @of_rat_inj

end M1F