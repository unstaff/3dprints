$fn=50;

use <threads.scad>

build = 3; // build 1=base, 2=lid, 3=both
camera = 2; // camera 0=none, 1=internal, 2=external
gpio = 0; // gpio 0=no cut_out, 1=top cut_out, 2 side cut out
wall = 2.0;
hdmi_recess = 0; // cable fits ok, not adaptors though
corner = 3.0;
tol = 0.3;
$fn = 100; // increase resolution

// 65 for original pizero with no camera connector
// 67 for pizero with camera connector
// 73  to give more radius for bending cable back internally
base_length = camera==1 ? 73.0 : 67.0;

base_width = 30;
hole2hole_l = 58;
hole2hole_w = 23;
hdmi_recess_w = 17.5;
hdmi_recess_h = 3.75;
support_offset = 3.5;
support_height = 1.0;
support_radius = 1.5;
support_size = 7.0;
usbpower_offset = 54.0;
usbusb_offset = 41.4;
usb_length = 9.25;
hdmi_offset = 12.4;
hdmi_length = 13.75;
cutout_height_offset = 1.0;
sd_offset = 16.7;
sd_width = 13.0;

lid_height = camera==1 ? 6.0 : 2.5; // 1.5 for no camera shallow, 6 for camera
board_thick = 1.35; // camera board is 0.9mm
connector_thick = 3.2;
screw_depth = 5.0;
screw_radius = 1.3;
gpio_centre_x = 32.5;
gpio_centre_y = 3.5;
gpio_length = 51.5;
gpio_width = 6;
gpio_recess_h = 1.2;
corner_size = 2.4;
base_height = support_height + board_thick + connector_thick + 1; // calculate required base_height

camera_hole = 8.5; // 8mm square
camera_x = 30.0;
camera_screw_centre_offset = 0.0;
camera_screw_x = 12.5;
camera_screw_y = 21.0; // 21mm screw spacing
camera_screw_r = 1; // m2
camera_cable_y = 20.0;
camera_cable_h = 1.0;

module round_cube(start,length,width,height,z_offset,cor) {
    hull()
    {
        translate([start,start,z_offset]) cylinder(height+wall,r=cor);
        translate([start+length,start,z_offset]) cylinder(height+wall,r=cor);
        translate([start+length,start+width,z_offset]) cylinder(height+wall,r=cor);
        translate([start,start+width,z_offset]) cylinder(height+wall,r=cor);
    }
}

module screwhole() {
    cylinder(wall+support_height+tol+board_thick*2,r=support_radius);
}

module corner_support() {

    difference()
    {
        union()
        {
            // strengthening flange
            translate([support_offset,support_offset,wall-0.1]) cylinder(r1=5,r2=3,h=2);

            // insert holder
            translate([support_offset,support_offset,wall-0.1]) cylinder(h=lid_height+connector_thick+0.1,r=3.2);
        }

        // hole through both
        translate([support_offset,support_offset,wall+lid_height+connector_thick-screw_depth]) cylinder(h=screw_depth+1,r=3.5/2);
    }
}

module cut_outs(height) {
    //translate([tol+hdmi_offset-0.5*hdmi_length,-wall-0.1,height]) cube([hdmi_length, wall+ 1.0,base_height]);
    translate([tol+usbusb_offset-0.5*usb_length,-wall-0.1,height]) cube([usb_length, wall+ 1.0,base_height]);
   // translate([tol+usbpower_offset-0.5*usb_length,-wall-0.1,height]) cube([usb_length, wall+ 1.0,base_height]);
    translate([-wall-0.1,tol+sd_offset-0.5*sd_width,height]) cube([wall+ 1.0,sd_width,base_height]);

    if (hdmi_recess==1)
    {
        translate([tol+hdmi_offset-0.5*hdmi_recess_w,-wall-0.1,wall]) cube([hdmi_recess_w, wall+ 0.1,base_height]);
    }

    if (camera==2)
    {
        translate([base_length - 2* wall,tol+0.5*(base_width-camera_cable_y),height]) cube([4*wall,camera_cable_y,camera_cable_h]);
    }

    if (gpio==2)
    {
        translate([tol + gpio_centre_x - gpio_length*0.5,tol+base_width-wall,height]) cube([gpio_length,4*wall,base_height]);
    }
}

module base_shell() {
    difference()
    {
        round_cube(corner-wall,base_length+2*tol+2*wall-2*corner,base_width+2*tol+2*wall-2*corner,base_height+2.5,0,corner);
        round_cube(corner-tol,base_length+4*tol-2*corner,base_width+4*tol-2*corner,base_height+3,wall,corner);
       translate([-1,-5,base_height+1.5]) cube([base_length+2,base_width+6,2]);
       translate([-1,-base_width-5,base_height+3]) cube([base_length+2,base_width+6,2]);
    }

    translate([-tol,-tol,0]) cube([support_size,support_size,support_height+wall]);
    translate([hole2hole_l+tol,-tol,0]) cube([support_size,support_size,support_height+wall]);
    translate([hole2hole_l+tol,hole2hole_w+tol,0]) cube([support_size,support_size+2*tol,support_height+wall]);
    translate([-tol,hole2hole_w+tol,0]) cube([support_size,support_size+2*tol,support_height+wall]);
}

module base() {
    difference()
    {
        base_shell();
        cut_outs(wall+support_height+board_thick-tol);
    }
        translate([tol+support_offset,tol+support_offset,-0.1]) screwhole();
        translate([tol+support_offset+hole2hole_l,tol+support_offset,-0.1]) screwhole();
        translate([tol+support_offset+hole2hole_l,tol+support_offset+hole2hole_w,-0.1]) screwhole();
        translate([tol+support_offset,tol+support_offset+hole2hole_w,-0.1]) screwhole();
}

module chanfrin(BaseWidth, TopWidth, Height, Length) {
CubePoints = [
  [  0,  0,  0 ],  //0
  [ Height,  (BaseWidth-TopWidth) / 2,  0 ],  //1
  [ Height,  BaseWidth - (BaseWidth-TopWidth) / 2,  0 ],  //2
  [  0,  BaseWidth,  0 ],  //3
  [  0,  0,  Length ],  //4
  [ Height,  (BaseWidth-TopWidth) / 2,  Length ],  //5
  [ Height,  BaseWidth - (BaseWidth-TopWidth) / 2,  Length ],  //6
  [  0,  BaseWidth,  Length ]]; //7
  
CubeFaces = [
  [0,1,2,3],  // bottom
  [4,5,1,0],  // front
  [7,6,5,4],  // top
  [5,6,2,1],  // right
  [6,7,3,2],  // back
  [7,4,0,3]]; // left

polyhedron( CubePoints, CubeFaces );
}

battery_w = 55;
battery_h = 6;
box_w = 60;
box_h = 10;
edge_rounded = 1.5;

translate([edge_rounded,edge_rounded+base_length,box_h]) rotate(-90,[0,0,1]) base();

difference() {
minkowski()
{
  cube([box_w,100,box_h]);
  sphere(r=edge_rounded);
}
translate([(box_w-battery_w)/2,-4,(box_h-battery_h)/2])
  cube([battery_w,100,battery_h]);
// chanfrin
translate([-10,battery_h*.5-edge_rounded,battery_h+(box_h-battery_h)/2])
    rotate(a=-90, v=[1,0,0])
        rotate(a=90, v=[0,1,0])
            chanfrin(battery_h,battery_h*.6,battery_h*.5,battery_w*2);
// USB slot
translate([-10,0,box_h/2-battery_h/4])
    cube([20,15,battery_h*.6]);
}


