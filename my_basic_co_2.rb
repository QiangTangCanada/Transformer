###############################################################################
#
#   Correction Processor
#
###############################################################################

include RBA

puts "--- correction start\n\n"

# cell_view = RBA::Application::instance.main_window.load_layout( \
#                                             "simple_rectangle.gds", 1)

cell_view = RBA::Application::instance.main_window.load_layout( \
                                            "simple_rectangle_backup.gds", 1)

ly        = cell_view.layout()
$top      = ly.cell("TOP")

l1        = ly.layer(RBA::LayerInfo::new(1, 0))
o2        = ly.insert_layer(RBA::LayerInfo::new(11, 0))
$o3       = ly.insert_layer(RBA::LayerInfo::new(12, 0))

$region_corrected = RBA::Region::new

tp        = RBA::TilingProcessor::new

tp.input( "i1", ly.begin_shapes($top.cell_index, l1))

class MyReceiver < RBA::TileOutputReceiver

   def put(ix, iy, tile, region, dbu, clip)
      puts "got region for tile #{ix + 1}, #{iy + 1}: " + 
           "#{region.to_s} #{clip} #{tile.to_s} dbu #{dbu}"

      army = RBA::DArmy::new(region)

      army.each_transformer do |dtransformer|

          puts "--- before splitting and shifting\n"

          bar_index_plane_1 = 0

          dtransformer.each_bar(1) do |bar|
             bar_length = bar.length
          
             split_plan_5 = RBA::SPlan::new
             split_plan_5.isometric(5)
             
             split_plan_2 = RBA::SPlan::new
             split_plan_2.isometric(2)

             split_plan_tail_head_mid = RBA::SPlan::new
             split_plan_tail_head_mid.abs_tail_head_middle(40, 80, 2)

             split_plan_tail_head_middle2 = RBA::SPlan::new
             split_plan_tail_head_middle2.rel_tail_head_middle(10, 50, 2)
             
             split_plan_tail_head_middle3 = RBA::SPlan::new
             split_plan_tail_head_middle3.add_percentage(5).  \
                                          add_percentage(10). \
                                          add_percentage(15). \
                                          add_percentage(20). \
                                          add_percentage(25)
             
             gplan_1 = RBA::GPlan::new("my_gauge_1", 20, 20, 1, 0.5)
             gplan_2 = RBA::GPlan::new("my_gauge_2", 10, 10, 1, 0.5)
             
             if bar.angle(1, 90, 90)
                # bar.splan(split_plan_5)
                # bar.splan(split_plan_tail_head_middle)
                # bar.splan(split_plan_tail_head_middle2)
                bar.splan(split_plan_tail_head_middle3)
                bar.gplan(gplan_1)
                bar.split
             else
                bar.splan(split_plan_2)
                bar.gplan(gplan_2)
                bar.split
             end

             bar_index_plane_1 = bar_index_plane_1 + 1
          end
          
          # Not implemented
          # if ! dtransformer.is_valid
          #   return
          
          bar_index_plane_2 = 0

          dtransformer.each_bar(2) do |bar|
             if bar_index_plane_2 % 2 == 1
                bar.shift(50)
             else
                bar.shift(100)
             end

             bar_index_plane_2 = bar_index_plane_2 + 1
          end          
          
          
          puts "--- after  splitting and shifting "
          
          new_polygon = dtransformer.polygon(2)
           
          $region_corrected.insert(new_polygon)

          puts "\n"
      end

      $top.shapes($o3).insert($region_corrected)

   end
end


tp.output("o2", MyReceiver::new)

tp.queue ("_output(o2, (i1))")

#tp.tile_size(     4,    4)
#tp.tile_border(   2,    2)

tp.tile_size(     10,   10)
tp.tile_border(    8,    8)

tp.threads = 2

tp.execute ("test")

ly.write("z3.gds")

RBA::Application::instance.main_window.load_layout("z3.gds", 1)


puts '--- correction end'



###############################################################################
#
#   END
#
###############################################################################
