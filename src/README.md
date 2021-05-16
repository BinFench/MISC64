The MISC64 architecture implementation is composed of multiple component blocks and pipeline stages.

Fetch - the fetch stage of the instruction pipeline.  Reads instruction memory and grabs multiple instructions for dispatch

Dispatch - the dispatch stage of the instruction pipeline.  Decodes instructions to assign to the execute units.  Uses register naming and reservations to ensure available resources for processing.

Issue - the issue stage of the instruction pipeline.  Assigns decoded instructions to their appropriate execute unit, and stalls instructions that have an unresolved dependency.

Execute - the execute stage of the instruction pipeline.  Receives issued instructions to execute using an ALU or memory module.

Retire - the retire stage of the instruction pipeline.  Receives executed instructions and retires them by writeback and restores reserved resources.

Context - the banked register files that store program context

Control - the modules that allow inter communication between the various components and stages.

Devices - These devices are memory mapped and are used to extend the functionality of the MISC processor.  Examples include interrupt lines for this processor or other processors, or external devices such as storage or processing units.
