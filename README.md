# VisualAnalysisFramework
A simple framework for processing and analyzing two-photon and widefield visual experiments

## Simple definitions
### Epochs
__blank_epoch__: gray screen at the beginning of each _repeat_
__on_epoch__: a single distinct stimulus _presentation_
__relax_epoch__: gray screen following each _on_epoch_ 
__base_epoch__: gray screen that prcedes each _on_epoch_

### Terms
__presentation__: [_base_epoch_ + _on_epoch_ + _relax_epoch]
__repeat__: [_blank_epoch_ + _presentation_ * n_presentations]

## Notes
This analysis framework is designed to work hand in hand with the Psychtoolbox stimulus framework that can be found here: <https://github.com/kevinksit/PsychtoolboxStimulusFramework>


#### To add
Some images showing the differences between presentations etc.
