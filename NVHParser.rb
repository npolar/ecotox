require 'simple-spreadsheet'

class NVHParser
    def initialize()
    end

    def valid_float?(str)
        !!Float(str) rescue false
    end

    def valid_int?(str)
        !!Integer(str) rescue false
    end

    def valid_date?(str)
        !!Time.mktime(*ParseDate.parsedate(str)) rescue false
    end

    def row_types(list)
        types = Array.new
        list.each do |elem|
            if self.valid_float?(elem)
                types << 'float'
            elsif self.valid_int?(elem)
                types << 'int'
            elsif self.valid_date?(elem)
                types << 'date'
            else
                types << 'string'
            end
        end

        return types
    end

    # TODO: probably nicer rubyish way to do this
    def has_numeric(types)
        types.each do |elem|
            if elem != 'string'
                return true
            end
        end
        
        return false
    end

    # returns [frequency, types]
    def detect_types(sheet)
        typelist_counts = Hash.new(0)
        sheet.first_row.upto(sheet.last_row) do |row|
            sample_row = Array.new()
            (0..row.size).each do |cell_index|
                sample_row << sheet.cell(row, cell_index)
            end
            types = row_types(sample_row)
            if self.has_numeric(types)
                typelist_counts[types] += 1
            end
        end

        # TODO: make this rubyish and nice
        total = 0
        max_count = 0
        best_types = nil

        typelist_counts.each_pair do |types, count|
            if count > max_count
                max_count = count
                best_types = types
            end
            total += count
        end

        return [max_count.to_f / total.to_f, best_types]
    end

    def parse(path)
        s = SimpleSpreadsheet::Workbook.read(path)
        s.selected_sheet = s.sheets.first

        info = self.detect_types(s)
        print info
    end
end

MyParser = NVHParser.new()
MyParser.parse(ARGV[0])
