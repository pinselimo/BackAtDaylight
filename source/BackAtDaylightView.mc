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
using Toybox.System;
using Toybox.Math;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Lang;
using Toybox.System;

class BackAtDaylightView extends WatchUi.SimpleDataField  {

    const RAD = Math.PI / 180;
    const JULIAN_YEAR_1970 = 2440588.0;
    const JULIAN_YEAR_2000 = 2451545.0;
    const FRAC_JULIAN_DAY = 0.0008;

    function initialize() {
        SimpleDataField.initialize();
        label = loadResource(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var distanceLeft = 8.0f;
        var speedNeeded = 12.0f;

        if(info has :distanceToDestination) {
            if(info.distanceToDestination != null) {
                distanceLeft = info.distanceToDestination;
            } else {
                distanceLeft = 42.0f;
            }
        }
        if (info has :currentLocation) {
            if (info.currentLocation != null) {
                var today = new Time.Moment(Time.today().value());
                var now = new Time.Moment(Time.now().value());

                var sunset = get_sunset(today, info.currentLocation);
                var time_left = sunset.subtract(now); // .value().toDouble();
                var hours_left = time_left.value().toDouble() / Time.Gregorian.SECONDS_PER_HOUR;
                
                // TODO: After the sunset, don't display negative speed
                speedNeeded = distanceLeft / hours_left;

            } else {
                speedNeeded = 63.0f;
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