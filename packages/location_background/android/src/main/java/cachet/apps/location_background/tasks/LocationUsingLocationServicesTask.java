package cachet.apps.location_background.tasks;

import cachet.apps.location_background.data.LocationOptions;

abstract class LocationUsingLocationServicesTask extends Task<LocationOptions> {
    final LocationOptions mLocationOptions;

    LocationUsingLocationServicesTask(TaskContext<LocationOptions> taskContext) {
        super(taskContext);

        mLocationOptions = taskContext.getOptions();
    }
}
