# Production Line Control Using Deep Reinforcement Learning

This project implements a dynamic control policy for a simulated production line using Deep Reinforcement Learning (DRL) to minimize operational costs, delays, and buffer congestion in a discrete-event manufacturing environment. The work was carried out as part of a diploma thesis at the Technical University of Crete.

## Overview

The project focuses on optimizing a production line with:
- **Five machines**, intermediate buffers, and an assembly unit.
- A **Proximal Policy Optimization (PPO)** agent trained to control machine activity in real time.
- A simulation model built in **MATLAB Simulink** and **SimEvents**.
- The agent observes buffer levels and machine states to make control decisions.
- Performance is compared against traditional heuristic methods, dynamic programming, and the **Advantage Actor-Critic (A2C)** algorithm.

Key results show that the PPO agent outperforms traditional methods in reducing costs and delays while maintaining low buffer congestion.

## Folder Structure

- Simulink/: Contains Simulink and SimEvents model files for the production line simulation.
- Scripts/: MATLAB scripts for training the PPO and A2C agents, utility functions, and evaluation scripts.
- Trained Agents/: Saved PPO and A2C agent models for reuse and testing.
- Figures/: Plots and diagrams, including reward curves and performance comparisons.
- Thesis pdf/: The final diploma thesis document in PDF format.

## Requirements

- MATLAB R2023a or later
- Simulink
- SimEvents
- Reinforcement Learning Toolbox
