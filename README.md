# VisualAnalysisFramework
A simple framework for processing and analyzing two-photon and widefield visual experiments

## Simple definitions
### Epochs
__blank_time__: gray screen at the beginning of each _repeat_  
__pre_time__: gray screen that precedes each _on_time_  
__on_time__: a single distinct stimulus _presentation_  
__post_time__: gray screen following each _on_time_   

### Terms
__presentation__: [_pre_time_ + _on_time_ + _post_time]  
__repeat__: [_blank_time_ + _presentation_ * n_presentations]  

## Notes
This analysis framework is designed to work hand in hand with the Psychtoolbox stimulus framework that can be found here: <https://github.com/kevinksit/PsychtoolboxStimulusFramework>