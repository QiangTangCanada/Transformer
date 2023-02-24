###############################################################################
#
#   Correction Processor [8]
#
###############################################################################

include RBA

puts "--- correction start\n\n"

ly = RBA::Layout::new()

ly.read("aa_mo_opc.gds")

$top      = ly.cell("TOPCELL")

l1        = ly.layer(RBA::LayerInfo::new(0, 0))
o2        = ly.insert_layer(RBA::LayerInfo::new(11, 0))
$o3       = ly.insert_layer(RBA::LayerInfo::new(12, 0))

tp        = RBA::TilingProcessor::new

tp.input( "i1", ly.begin_shapes($top.cell_index, l1))


$split_plan_5 = RBA::SPlan::new
$split_plan_5.isometric(5) 
             
$split_plan_2 = RBA::SPlan::new
$split_plan_2.isometric(2)

$split_plan_tail_head_mid = RBA::SPlan::new
$split_plan_tail_head_mid.abs_tail_head_middle(40, 80, 2)

$split_plan_tail_head_middle2 = RBA::SPlan::new
$split_plan_tail_head_middle2.rel_tail_head_middle(10, 50, 2)
             
$split_plan_tail_head_middle3 = RBA::SPlan::new
$split_plan_tail_head_middle3.add_percentage( 5).\
                              add_percentage(10).\
                              add_percentage(15).\
                              add_percentage(20).\
                              add_percentage(25)          
                    
gplan_1 = RBA::GPlan::new("my_gauge_1", 20, 20, 1, 0.5)
gplan_2 = RBA::GPlan::new("my_gauge_2", 10, 10, 1, 0.5)


class MyReceiver < RBA::TileOutputReceiver

   def put(ix, iy, tile, region, dbu, clip)
      puts "got region for tile #{ix + 1}, #{iy + 1}"

      region_corrected = RBA::Region::new

      army = RBA::DArmy::new(region)

      army.each_transformer do |dtransformer|

          dtransformer.each_bar(2) do |bar|
             if bar.angle(1, 90, 90)
                bar.splan($split_plan_5)
                bar.split
             else
                bar.splan($split_plan_2)
                bar.split
             end
          end
          
          bar_index_plane_2 = 0

          dtransformer.each_bar(3) do |bar|
             if bar_index_plane_2 % 2 == 1
                bar.shift(5)
             else
                bar.shift(10)
             end

             bar_index_plane_2 = bar_index_plane_2 + 1
          end          
                    
          new_polygon = dtransformer.polygon(3)
           
          region_corrected.insert(new_polygon)
      end

      $top.shapes($o3).insert(region_corrected)

   end
end


tp.output("o2", MyReceiver::new)

tp.queue ("_output(o2, (i1))")

RBA::Logger::verbosity = 21

tp.tile_size(    50,  50)
tp.tile_border(   5,   5)

tp.threads = 100

tp.execute ("test")

ly.write("aa_mo_opc_corrected_2.gds")

puts '--- correction end'



###############################################################################
#
#   END
#
###############################################################################

