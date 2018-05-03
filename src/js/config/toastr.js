/**
 * Copyright 2018 CS Systèmes d'Information
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @file Configure toastr component
 */

/**
 * Configure the container of the toast-messages
 * @class ikats_HMI.Config.toastrConfig
 * @memberOf ikats_HMI.Config
 */
angular.module("ikatsapp.config").config(["toastrConfig", function (toastrConfig) {
    angular.extend(toastrConfig, {
        autoDismiss: false,
        containerId: "toast-container",
        maxOpened: 0,
        newestOnTop: false,
        positionClass: "toast-bottom-right",
        preventDuplicates: false,
        preventOpenDuplicates: false,
        target: "body"
    });
}]);
