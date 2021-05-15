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
using Toybox.Test;
using Toybox.Time;
using Toybox.Position;

(:debug) class TestMethods {

    (:test)
    function test_sunset_utc_equator(logger) {
        var backAtDaylightView = new BackAtDaylightView();
        var pos = new Position.Location(
            {
                :latitude => 0.0,
                :longitude => 0.0,
                :format => :degrees
            }
            );
        var moment = new Time.Moment(1577858400); // 1/1/2020

        var sunset = backAtDaylightView.get_sunset(moment, pos);
        var info = Time.Gregorian.utcInfo(sunset, Time.FORMAT_SHORT);
        var dateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$",
                [
                    info.hour,
                    info.min,
                    info.sec,
                    info.day,
                    info.month,
                    info.year
                ]);
        logger.debug("Sunset at equator: " + dateString);

        return Math.round(sunset.value()) == 1577902086;
    }

    (:test)
    function test_sunset_utc_south(logger) {
        var backAtDaylightView = new BackAtDaylightView();
        var pos = new Position.Location(
            {
                :latitude => -45.0,
                :longitude => 0.0,
                :format => :degrees
            }
            );
        var moment = new Time.Moment(1577858400); // 1/1/2020

        var sunset = backAtDaylightView.get_sunset(moment, pos);
        var info = Time.Gregorian.utcInfo(sunset, Time.FORMAT_SHORT);
        var dateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$",
                [
                    info.hour,
                    info.min,
                    info.sec,
                    info.day,
                    info.month,
                    info.year
                ]);
        logger.debug("Sunset 45° south: " + dateString);

        return Math.round(sunset.value()) == 1577908242;
    }

    (:test)
    function test_sunset_utc_north(logger) {
        var backAtDaylightView = new BackAtDaylightView();
        var pos = new Position.Location(
            {
                :latitude => 45.0,
                :longitude => 0.0,
                :format => :degrees
            }
            );
        var moment = new Time.Moment(1577858400); // 1/1/2020

        var sunset = backAtDaylightView.get_sunset(moment, pos);
        var info = Time.Gregorian.utcInfo(sunset, Time.FORMAT_SHORT);
        var dateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$",
                [
                    info.hour,
                    info.min,
                    info.sec,
                    info.day,
                    info.month,
                    info.year
                ]);
        logger.debug("Sunset 45° north: " + dateString);

        return Math.round(sunset.value()) == 1577896176;
    }

    (:test)
    function test_sunset_east_west(logger) {
        var backAtDaylightView = new BackAtDaylightView();
        var pos = new Position.Location(
            {
                :latitude => 0.0,
                :longitude => 180.0,
                :format => :degrees
            }
            );
        var moment = new Time.Moment(1577858400); // 1/1/2020

        var sunset_east = backAtDaylightView.get_sunset(moment, pos);

        var info = Time.Gregorian.utcInfo(sunset_east, Time.FORMAT_SHORT);
        var dateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$",
                [
                    info.hour,
                    info.min,
                    info.sec,
                    info.day,
                    info.month,
                    info.year
                ]);
        logger.debug("Sunset east: " + dateString);

        pos = new Position.Location(
            {
                :latitude => 0.0,
                :longitude => 180.0,
                :format => :degrees
            }
            );

        var sunset_west = backAtDaylightView.get_sunset(moment, pos);

        info = Time.Gregorian.utcInfo(sunset_west, Time.FORMAT_SHORT);
        dateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$",
                [
                    info.hour,
                    info.min,
                    info.sec,
                    info.day,
                    info.month,
                    info.year
                ]);
        logger.debug("Sunset west: " + dateString);

        return sunset_east.value() == sunset_west.value();
    }
}
