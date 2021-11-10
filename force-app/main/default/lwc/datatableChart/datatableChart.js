import { LightningElement, api, track } from 'lwc';
import chartJSLib from '@salesforce/resourceUrl/ChartJS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

const chartColors = {
    black:	'rgb(0,0,0)',
    red:	'rgb(255,0,0)',
    lime:	'rgb(0,255,0)',
    blue:	'rgb(0,0,255)',
    yellow:	'rgb(255,255,0)',
    cyan:	'rgb(0,255,255)',
    magenta:	'rgb(255,0,255)',
    silver:	'rgb(192,192,192)',
    gray:	'rgb(128,128,128)',
    maroon:	'rgb(128,0,0)',
    olive:	'rgb(128,128,0)',
    green:	'rgb(0,128,0)',
    purple:	'rgb(128,0,128)',
    teal:	'rgb(0,128,128)',
    navy:	'rgb(0,0,128)'
};

export default class DatatableChart extends LightningElement {

    @api type;
    @api title;
    @api records;
    @api fields;
    @api chartColour;
    @api chartLabelField;
    @api chartDataPointField;

    @track isLoading = true;
    @track error;

    connectedCallback() {
        if (!this.type) this.type = 'bar';
        if (!this.chartColour) {
            this.error = 'Chart colour required to draw the chart!';
        } else if (!this.chartLabelField) {
            this.error = 'Chart label field required to get labels!';
        } else if (!this.chartDataPointField) {
            this.error = 'Chart data point field required to get data points!';
        } else {
            this.error = undefined;
        }
    }

    renderedCallback() {

        if (this.chartjsInitialized) return;
        this.chartjsInitialized = true;
        this.isLoading = false;

        Promise.all([
            loadScript(this, chartJSLib + '/js/utils.js'),
            loadScript(this, chartJSLib + '/js/Chart.bundle.min.js'),
            loadStyle(this, chartJSLib + '/css/Chart.min.css')
        ]).then(() => {
            this.generateChart();
        })
        .catch(error => {
            console.error(error);
        });
    }

    get dataLabels () {
        return this.records.map(record => this.getData(this.chartLabelField, record));
    }

    get dataPoints () {
        return this.records.map(record => this.getData(this.chartDataPointField, record));
    }

    get chartColourFill () {
        return !['line', 'bar', 'radar'].includes(this.type);
    }

    get chartColours () {
        return this.chartColourFill ?
          Object.values(chartColors).slice(0, this.dataLabels.length > 15 ? 14 : this.dataLabels.length - 1)
          : chartColors[this.chartColour];
    }

    get chartData () {

        const chartColours = this.chartColours;

        const chartData = {
            labels: this.dataLabels,
            datasets: [{
                label: 'Dataset 1',
                backgroundColor: chartColours,
                borderColor: chartColours,
                fill: this.chartColourFill,
                yAxisID: 'y-axis-1',
                data: this.dataPoints
            }]
        };

        return chartData;
    }

    get dataSet () {

        const dataSet = {
            type: this.type,
            data: this.chartData,
            options: {
                responsive: true,
                title: {
                    display: !!this.title,
                    text: this.title
                },
                legend: {
                    display: this.chartColourFill,
                },
                tooltips: {
                    mode: 'index',
                    intersect: true
                },
                scales: {
                    yAxes: [{
                        type: 'linear',
                        display: true,
                        position: 'left',
                        id: 'y-axis-1',
                    }],
                }
            }
        };

        return dataSet;
    }

    generateChart () {
        const ctx = this.template.querySelector('canvas').getContext('2d');
        new window.Chart(ctx, this.dataSet);
    }

    getData (fieldName, record) {
        let data;
        let field = this.fields.filter(field => field.fieldName === fieldName)[0];
        field.fieldName.split('.').forEach((fN) => {
            data = data ? data[fN] : record[fN];
        });
        if ((field.type === 'date' || field.type === 'datetime') && !!data) {
            data = new Date(data).toLocaleString();
        }
        return data;
    }
}