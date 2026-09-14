%import palloc
%import textio

mem {
    bool initialized = false

    sub realloc(uword old_ptr, uword old_size, uword new_size) -> uword {

        if not initialized {
            initialized = palloc.init_loram()
        }

        if old_size == 0 or old_ptr == 0 {
            return palloc.alloc(new_size)
        }

        if new_size == 0  {
            palloc.free(old_ptr)
            return 0
        }

        uword new_ptr
        if new_size <= old_size {
            new_ptr = old_ptr
            if new_size <= old_size / 2 {
                new_ptr = palloc.alloc(new_size)
                sys.memcopy(old_ptr, new_ptr, new_size)
                palloc.free(old_ptr)
            } 
        } else {
            new_ptr = palloc.alloc(new_size)
            sys.memcopy(old_ptr, new_ptr, old_size)
            palloc.free(old_ptr)
        }
        if new_ptr == 0 {
            txt.print("panic: out of memory")
            sys.exit(1)
        }
        return new_ptr
    }

    sub alloc(uword size) -> uword {
        return realloc(0, 0, size)
    }

    sub free(uword ptr) {
        void realloc(ptr, 0, 0) 
    }

    sub grow(uword old_size) -> uword {
        return if old_size < 8 then 8  else old_size * 2
    }

}
