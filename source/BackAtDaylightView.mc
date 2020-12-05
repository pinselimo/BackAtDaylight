/* Garmin data field showing at which minimum average speed to reach a destination before sunset.
    Copyright (C) 2020 Simon Plakolb

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
using Toybox.Math;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.System;

class BackAtDaylightView extends WatchUi.SimpleDataField  {

    const RAD = Math.PI / 180;
    const JULIAN_YEAR_1970 = 2440588.0;
    const JULIAN_YEAR_2000 = 2451545.0;
    const FRAC_JULIAN_DAY = 0.0008;

    var unit = " kph";
    var adjustment = 1000;

    function initialize() {
        SimpleDataField.initialize();
        label = loadResource(Rez.Strings.label);

        var distanceUnits = System.getDeviceSettings().distanceUnits;

        if (distanceUnits == System.UNIT_STATUTE) {
            unit = " mph";
            adjustment *= 1.609344;
        }
    }

    function compute(info) {
        var speedNeeded = "_.__" + unit;

        if(info has :distanceToDestination and info has :currentLocation) {
            if(info.distanceToDestination != null and info.currentLocation != null) {
                var distanceLeft = info.distanceToDestination;
 
                var today = new Time.Moment(Time.today().value());
                var now = new Time.Moment(Time.now().value());
                var sunset = get_sunset(today, info.currentLocation);

                if (sunset.greaterThan(now)) {
                    var time_left = sunset.subtract(now);
                    var hours_left = time_left.value().toDouble() / Time.Gregorian.SECONDS_PER_HOUR;
                    
                    speedNeeded = distanceLeft / (adjustment * hours_left);
                    speedNeeded = speedNeeded.format("%3.2f") + unit;
                } else {
                    speedNeeded = "Lightspeed";
                }
            }
        }
        return speedNeeded;
    }

    function get_sunset(moment, pos) {
        var loc = pos.toRadians();
        var lat = loc[0];
        var lon = loc[1];

        var julian_day = JULIAN_YEAR_1970 + Math.round(moment.value().toDouble() / Time.Gregorian.SECONDS_PER_DAY) + 0.5;
        var n = julian_day - JULIAN_YEAR_2000 + FRAC_JULIAN_DAY;

        // Mean solar noon
        var j_star = n - lon / (2*Math.PI);
        
        var m = 6.240059967 + 0.0172019715 * j_star;

        // Center
        var c = (1.9148*Math.sin(m) + 0.02*Math.sin(2*m) + 0.0003*Math.sin(3*m)) * RAD;

        // Ecliptic longitude
        var lambda = m + c + Math.PI + 1.796593063;
        
        // Solar transit
        var j_transit = JULIAN_YEAR_2000 + j_star + 0.0053*Math.sin(m) - 0.0069*Math.sin(2*lambda);

        // Declination of the sun
        var delta = Math.asin(Math.sin(lambda) * Math.sin(23.44*RAD));

        // Hour angle
        var omega_zero = (Math.sin(-0.833*RAD) - Math.sin(lat)*Math.sin(delta)) / (Math.cos(lat)*Math.cos(delta));
        
        var j_sunset = j_transit + Math.acos(omega_zero)/(2*Math.PI);

        return new Time.Moment((j_sunset - JULIAN_YEAR_1970) * Time.Gregorian.SECONDS_PER_DAY);
    }
}