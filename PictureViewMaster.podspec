
Pod::Spec.new do |s|
  s.name         = "PictureViewMaster"
  s.version      = "2.0"
  s.summary      = "Image projector for image views"
  s.description  = <<-DESC
                   Picture View Master lets you add UIImagesViews that can be present in a View Controller ( as if they were being projected ) and let the 
                   user zoom, rotate, and move it.
                   DESC

  s.homepage     = "https://github.com/inaka/PictureViewMaster"
  s.screenshots  = "https://raw.githubusercontent.com/inaka/PictureViewMaster/master/PictureImageView.gif"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.authors    = { "Andrés Gerace" => "https://www.github.com/agerace", "Inaka" => "http://inaka.net" }
  s.social_media_url   = "http://twitter.com/inaka"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/inaka/PictureViewMaster.git", :tag => s.version }
  s.source_files  = "PictureViewMaster/**/*.swift"
end