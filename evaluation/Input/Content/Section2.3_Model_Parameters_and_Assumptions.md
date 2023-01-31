### 2.3.1 Absorption

For oral administration of digoxin, the following parameters play a role with regards to the absorption kinetics of a compound, which can be estimated with PBPK: solubility, lipophilicity and intestinal permeability. To accurately predict the digoxin plasma concentrations following intravenous and oral administration, the relative expression of P-gp in the intestinal mucosa was increased (3.57-fold) compared to the PK-Sim database RT-PCR expression profile (see table below). This factor has been identified in an optimization that included digoxin plasma concentrations and fraction excreted to urine data following intravenous and oral administration plus digoxin excreted to duodenum measurements after intravenous administration [Caldwell 1976](#5-references). The optimized P-gp expression profile shows highest expression in small intestinal mucosa (1.41 µmol/L), followed by kidney (1.00 µmol/L), large intestinal mucosa (0.56 µmol/L), liver (0.27 µmol/L) and tissues of lower expression. Implementation of transport by OATP (4C1) did not improve the model performance and was not used in the final model. 

| **Protein** | **Mean reference concentration [µmol protein/L in the tissue of highest expression]** | **Geometric standard deviation of reference concentration** | **Relative expression in the different organs (PK-Sim expression database profile)** | Half-life liver [h] | Half-life intestine [h] |
| :-------------- | ----------- | ----------------------------------- | ------------------------------------------------ | --------------- | --------------- |
| P-gp (efflux) | 1.41 optimized | 1.60 ([Prasad 2014](#5-references)) | RT-PCR, with the relative expression in intestinal mucosa increased by factor 3.57 (optimized)([Nishimura 2005](#5-references)) | 36 | 23 |

### 2.3.2 Distribution

Digoxin is reported to have a large volume of distribution due to extensive tissue binding and to be mainly excreted unchanged to urine (50 - 70%) while the remainder of a dose is eliminated by hepatic metabolism and biliary excretion [Ochs 1978, Bauer 2008](#5-references). Implementation of target-binding to the ATPase Na+/K+ transporting subunit alpha 2 (ATP1A2) was crucial, to mechanistically describe the large volume of distribution and the long plasma half-life of digoxin. 

It has reported fraction unbound of digoxin ranges from 70 to 77.9% ([Hinderling 1984, Obach 2008, Neuhoff 2013](#5-references)).  

After testing the available organ-plasma partition coefficient and cell permeability calculation methods built in PK-Sim, observed clinical data was best described by choosing the partition coefficient calculation method by Rodgers and Rowland, and PK-Sim standard cell permeability calculation method. Specific organ permeability normalized to surface area was automatically calculated by PK-Sim.

### 2.3.3 Metabolism and Elimination

The final digoxin model applies target-binding to the ATPase Na+/K+ transporting subunit alpha 2 (ATP1A2) , transport by P-gp in various organs including gut, liver and kidney, an unspecific hepatic metabolic clearance and glomerular filtration.

