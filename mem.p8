%import palloc

mem {
    bool initialized = false

    sub alloc(uword old_ptr, uword old_size, uword new_size) -> uword {

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
        return new_ptr
    }

    sub grow(uword old_size) -> uword {
        return if old_size < 8 then 8  else old_size * 2
    }

}
