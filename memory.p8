%import palloc
%import util

memory {
    bool initialized = false

    sub init() {
        if initialized return
        uword memtop = util.get_memtop()
        if not palloc.init(sys.progend(), memtop) {
            util.panic("heap initialization failure")
        }
        initialized = true
    }

    sub GROW_CAPACITY(uword capacity) -> uword {
        return if (capacity < 8) 8 as uword else capacity * 2
    }

    sub GROW_ARRAY(uword size, uword oldPtr, 
                   uword oldCount, uword newCount) -> uword {
        return allocate(oldPtr, size * oldCount, size * newCount)
    }

    sub FREE_ARRAY(uword size, uword pointer, uword oldCount) {
        void allocate(pointer, size * oldCount, 0)
    }
       
    ; all-singing, all-dancing allocator. handles alloc, free, and realloc
    sub allocate(uword oldPointer, uword oldSize, uword newSize) -> uword {

        if not initialized init()

        if newSize > oldSize / 2 and newSize < oldSize {
            return oldPointer
        }

        uword newPointer = palloc.alloc(newSize)
        if newPointer == 0 and newSize > 0 {
            util.panic("out of memory")
        }

        if oldPointer != 0 {
            uword copySize = min(oldSize, newSize)
            sys.memcopy(oldPointer, newPointer, copySize)
            palloc.free(oldPointer)
        }

        return newPointer
    }

    alias free_space = palloc.free_space
}
