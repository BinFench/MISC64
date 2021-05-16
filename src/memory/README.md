The memory addressing in MISC64 is, unsurprisingly, 64 bits.
As of right now, 64 bits worth of memory addressing is far more memory than is reasonable or expected at this point in time.  As for the future, the 128 bit ISA extension should meet any massive data need.
Because of this resource real estate, it was decided that MISC64 would communicate throughout the core with memory mapped devices.

Memory Addressing Strategy:

First byte: Jurisdiction Selector
First bit - Memory mapped device
Next bit - Interrupt line
Next 6 bits - Interrupt address

Next 2 bytes: Device Addressing

Last byte: Format
First bit - Stall on response
Next bit - Read/Write
Last 6 bits - General Purpose Addressing

Based on the context state, memory accesses may have a virtual mapping through the MMU.  In all context states, the MMU may return an interrupt for invalid memory accesses, or signal a stall for a memory miss or while awaiting a device response.

User level programs running on an OS may only be able to use the first byte of memory mapped I/O.  This means that user level programs can only interrupt, and cannot directly communicate with devices.  This is a security measure, as the user level programs can interrupt to trap into a syscall that will communicate with a device.  A priviledged program can interrupt and access devices.

Caching includes store buffers and fetching spacially local chunks of memory for fast contigious read/write operations.  Some space prediction may be implemented to prefetch the cache to eliminate memory missing stalls.
