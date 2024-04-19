class LinkedList

    attr_accessor :head

    def initialize()
        @head = nil
    end

    def append(value)
        if last() == nil
            @head = Segment.new(value)
        else
            last().next = Segment.new(value)
        end
    end

    def at(index)
        if @head == nil
            return nil
            # TODO Raise index out of range fel
        end
        follower = @head
        if index == 0
            return follower
        end
        for i in (0..index-1) do
            if follower.next == nil
                # TODO Raise index out of range fel
            else
                follower = follower.next
            end
        end
        return follower
    end

    def size()
        if @head == nil
            return 0
        else
            counter = 0
            follower = @head
            while true
                if follower == nil
                    return counter
                    break
                else
                    counter += 1
                    follower = follower.next
                end
            end
        end
    end

    def pop()
        seg = last()
        prev = at(size()-2)
        prev.next = nil
        return seg
    end

    def remove_at(index)
        curr = at(index)
        prev = at(index-1)
        prev.next = curr.next
    end

    def replace_at(index, val)
        location = at(index)
        location.value = val
    end

    def last()
        if @head == nil
            return nil
        else
            follower = @head
            while true
                if follower.next == nil
                    return follower
                    break
                else
                    follower = follower.next
                end
            end
        end
    end

    def print()
        to_print = "["
        if @head == nil
            to_print += "]"
            return to_print
        else
            follower = @head
            while true
                to_print += follower.value.to_s
                if follower.next == nil
                    to_print += "]"
                    break
                else
                    to_print += ", "
                    follower = follower.next
                end
            end
        end

        return to_print
    end
end



class Segment

    attr_accessor :value, :next

    def initialize(value, n = nil)
        @value = value
        @next = n
    end
end


l = LinkedList.new()

l.append(1)
l.append(29)
l.append(3)
l.append(10)
l.append(22)
l.append(69)

# p l.size()
# l.replace_at(2, 420)
# p l.size()

# p l.at(2)

puts l.print()
