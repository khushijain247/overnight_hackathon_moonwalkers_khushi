import streamlit as st
import numpy as np
import joblib

# ---------- LOAD TRAINED MODEL ONCE ----------
@st.cache_resource
def load_model():
    return joblib.load("fraud_tree_model.pkl")

model = load_model()

# ---------- RISK LEVEL MAPPING FUNCTIONS ----------
def level_large_deposits_exceed_capacity(ratio):
    if ratio <= 1.2:
        return 0
    elif ratio <= 2.0:
        return 1
    else:
        return 2

def level_registration_changes(changes_last_6_months):
    if changes_last_6_months == 0:
        return 0
    elif changes_last_6_months <= 2:
        return 1
    else:
        return 2

def level_rapid_transfers(fraction_transferred_out_within_7_days):
    if fraction_transferred_out_within_7_days <= 0.3:
        return 0
    elif fraction_transferred_out_within_7_days <= 0.7:
        return 1
    else:
        return 2

def level_declared_vs_sales_mismatch(rel_mismatch):
    if rel_mismatch <= 0.2:
        return 0
    elif rel_mismatch <= 0.5:
        return 1
    else:
        return 2

def level_multiple_entities_same_owner(count_entities):
    if count_entities <= 1:
        return 0
    elif count_entities == 2:
        return 1
    else:
        return 2

def level_high_subsidy_low_farmland(ratio_to_district_median):
    if ratio_to_district_median <= 1.2:
        return 0
    elif ratio_to_district_median <= 1.8:
        return 1
    else:
        return 2

def level_overlapping_claims(num_overlaps):
    if num_overlaps == 0:
        return 0
    elif num_overlaps == 1:
        return 1
    else:
        return 2

def level_fictitious_docs(num_inconsistencies):
    if num_inconsistencies == 0:
        return 0
    elif num_inconsistencies == 1:
        return 1
    else:
        return 2

# ---------- STREAMLIT UI ----------
st.title("Subsidy Fraud Risk Scoring Demo")

st.subheader("Input dealer / entity behaviour")

col1, col2 = st.columns(2)

with col1:
    total_subsidy = st.number_input("Total subsidy received (₹)", min_value=0.0, value=100000.0)
    capacity_subsidy = st.number_input("Estimated capacity-based subsidy (₹)", min_value=1.0, value=80000.0)
    reg_changes = st.number_input("Registration / yield changes in last 6 months", min_value=0, value=0, step=1)
    rapid_transfer_frac = st.slider("Fraction of subsidy transferred out within 7 days", 0.0, 1.0, 0.2, 0.05)
    declared_prod = st.number_input("Declared production (kg)", min_value=1.0, value=10000.0)

with col2:
    actual_sales = st.number_input("Actual sales (kg)", min_value=0.0, value=9000.0)
    entities_same_owner = st.number_input("Number of entities with same owner/premises", min_value=1, value=1, step=1)
    ratio_subsidy_farmland = st.number_input("Subsidy per hectare / district median", min_value=0.0, value=1.0)
    overlapping_claims = st.number_input("Number of overlapping subsidy claims", min_value=0, value=0, step=1)
    doc_inconsist = st.number_input("Number of inconsistencies in docs", min_value=0, value=0, step=1)

if st.button("Predict Risk"):
    # --- compute continuous helpers ---
    ratio_capacity = total_subsidy / max(capacity_subsidy, 1.0)
    rel_mismatch = abs(declared_prod - actual_sales) / max(declared_prod, 1.0)

    # --- map to 0/1/2 ---
    L1 = level_large_deposits_exceed_capacity(ratio_capacity)
    L2 = level_registration_changes(reg_changes)
    L3 = level_rapid_transfers(rapid_transfer_frac)
    L4 = level_declared_vs_sales_mismatch(rel_mismatch)
    L5 = level_multiple_entities_same_owner(entities_same_owner)
    L6 = level_high_subsidy_low_farmland(ratio_subsidy_farmland)
    L7 = level_overlapping_claims(overlapping_claims)
    L8 = level_fictitious_docs(doc_inconsist)

    X_new = np.array([[L1, L2, L3, L4, L5, L6, L7, L8]])
    pred_label = model.predict(X_new)[0]

    st.markdown(f"### Predicted risk level: **{pred_label.upper()}**")

    st.write("Discretized feature levels (0 = low, 1 = medium, 2 = high):")
    st.json({
        "LargeOrFrequentDepositsExceedCapacity": int(L1),
        "FrequentRegistrationChangesBeforeDisbursement": int(L2),
        "RapidTransfersToUnlinkedAccounts": int(L3),
        "DeclaredProductionVsSalesMismatch": int(L4),
        "MultipleEntitiesSameOwnerOrPremises": int(L5),
        "HighSubsidyInLowFarmlandArea": int(L6),
        "OverlappingSubsidyClaims": int(L7),
        "FictitiousOrManipulatedDocs": int(L8),
    })
