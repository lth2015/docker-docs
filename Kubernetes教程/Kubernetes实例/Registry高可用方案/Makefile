# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY:	build push

IMAGE = yeepay/registry
TAG = 2.1

build:	
	docker build -t $(IMAGE):$(TAG) .

push:	
	docker push registry.docker:5000/$(IMAGE):$(TAG)

run: 
	docker run -d -p 5000:5000 --restart=always --name registry -v ${PWD}/images/:/var/lib/registry $(IMAGE):$(TAG)

rm: 
	docker rm -f registry

clean:	
	docker rmi -f $(IMAGE):$(TAG)

deploy:
	kubectl create -f registry-rc.yaml --validate=false
	kubectl create -f registry-svc.yaml

clear:
	kubectl delete -f registry-rc.yaml
	kubectl delete -f registry-svc.yaml
